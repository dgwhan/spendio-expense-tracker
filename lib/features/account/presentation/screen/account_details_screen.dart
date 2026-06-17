import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:spend_io_app/core/widgets/input/app_search_bar.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/shared/widgets/date_picker/app_custome_date_picker_sheet.dart';
import 'package:spend_io_app/features/account/presentation/widgets/filter/account_detail_filter_capsule.dart';
import 'package:spend_io_app/features/account/presentation/widgets/hero/account_detail_hero_card.dart';
import 'package:spend_io_app/features/account/presentation/widgets/transaction/account_detail_summary_pills.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/account_transaction_feed.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_details_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/screen/utils/account_actions.dart';
import 'package:spend_io_app/features/account/presentation/widgets/edit_account_bottom_sheet.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';

class AccountDetailsScreen extends StatelessWidget {
  final AccountEntity account;
  const AccountDetailsScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountDetailsViewModel>(
      create: (_) => AccountDetailsViewModel(),
      child: _AccountDetailsScreenBody(
          targetAccountId: account.id, initialAccount: account),
    );
  }
}

class _AccountDetailsScreenBody extends StatefulWidget {
  final String targetAccountId;
  final AccountEntity initialAccount;

  const _AccountDetailsScreenBody({
    required this.targetAccountId,
    required this.initialAccount,
  });

  @override
  State<_AccountDetailsScreenBody> createState() =>
      _AccountDetailsScreenBodyState();
}

class _AccountDetailsScreenBodyState extends State<_AccountDetailsScreenBody> {
  bool _hasBeenUpdated = false;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<TransactionViewModel>()
            .loadByAccount(widget.targetAccountId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(
      BuildContext context, AccountViewModel accountVM, AccountEntity account) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogCtx) => AppConfirmationDialog(
        title: 'Delete Account',
        content:
            'Are you sure you want to delete this account? This action cannot be undone.',
        confirmLabel: 'Delete',
        cancelLabel: 'Cancel',
        isDestructive: true,
        onConfirm: () {
          final localId = account.userId;
          final currentUser = FirebaseAuth.instance.currentUser;
          final String remoteUid = currentUser?.uid ?? '';

          accountVM
              .deleteAccount(
            localId,
            remoteUid,
            account.id,
          )
              .then((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context, AccountDetailsAction.deleted);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    // Lắng nghe danh sách ví sống liên tục từ Provider để update HeroCard tại trận
    final accountVM = context.watch<AccountViewModel>();
    final matches =
        accountVM.accounts.where((acc) => acc.id == widget.targetAccountId);

    if (matches.isEmpty && _hasBeenUpdated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final account = matches.isNotEmpty ? matches.first : widget.initialAccount;

    // 🌟 1. Đọc danh sách giao dịch sống từ Provider (Trigger re-build khi DB biến động)
    final allTransactions =
        context.watch<TransactionViewModel>().state.transactions;

    // 🌟 2. Đồng bộ luồng ví & khởi tạo bộ lọc phẳng ngầm ở frame kế tiếp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentUser = FirebaseAuth.instance.currentUser;
        final String remoteUid = currentUser?.uid ?? '';

        context
            .read<AccountViewModel>()
            .loadAccounts(account.userId, remoteUid);
        context
            .read<AccountDetailsViewModel>()
            .initialize(account, allTransactions);
      }
    });

    // Lắng nghe state bộ lọc của AccountDetailsViewModel
    final detailsVM = context.watch<AccountDetailsViewModel>();
    final filterState = detailsVM.filterState;
    final ledgerState = detailsVM.ledgerState;

    // Bọc mảng an toàn để UI tự tính toán Thu/Chi không bị delay nhịp render
    final List<TransactionEntity> liveFiltered =
        (ledgerState?.filteredTransactions != null)
            ? ledgerState!.filteredTransactions
            : [];

    double liveTotalReceived = 0;
    double liveTotalSpent = 0;

    for (final tx in liveFiltered) {
      if (tx.type == TransactionType.expense) {
        liveTotalSpent += tx.amount;
      } else {
        liveTotalReceived += tx.amount;
      }
    }

    String activeRangeDisplay = filterState.activeRangeLabel;
    if (activeRangeDisplay == 'Custom Range...' &&
        filterState.customDateRange != null) {
      final range = filterState.customDateRange!;
      activeRangeDisplay =
          '${DateFormat('MMM d').format(range.start)} - ${DateFormat('MMM d, yyyy').format(range.end)}';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(
              context,
              _hasBeenUpdated
                  ? AccountDetailsAction.updated
                  : AccountDetailsAction.none);
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            // 🌟 CHỨC NĂNG KÉO ĐỂ REFRESH TOÀN TRANG (SẠCH LỖI ASYNC GAPS)
            onRefresh: () async {
              final currentUser = FirebaseAuth.instance.currentUser;
              final String remoteUid = currentUser?.uid ?? '';

              // 1. Kéo dữ liệu ví mới nhất từ SQLite
              await context.read<AccountViewModel>().loadAccounts(
                    account.userId,
                    remoteUid,
                    forceRefresh: true,
                  );

              // 🔥 KHIÊN PHÒNG VỆ: Nếu trong lúc đang await mà user lỡ bấm thoát màn hình -> Dừng luồng luôn
              if (!context.mounted) return;

              // 2. Kéo dữ liệu giao dịch mới nhất của ví hiện tại lên RAM
              await context
                  .read<TransactionViewModel>()
                  .loadByAccount(widget.targetAccountId);
            },
            child: CustomScrollView(
              // Physics bắt buộc để cơ chế kéo RefreshIndicator hoạt động ngon lành trên CustomScrollView
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // 1. APP BAR
                SliverAppBar(
                  pinned: true,
                  backgroundColor: backgroundColor,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: primaryTextColor),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(
                            context,
                            _hasBeenUpdated
                                ? AccountDetailsAction.updated
                                : AccountDetailsAction.none);
                      }
                    },
                  ),
                  title: Text(
                    account.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: primaryTextColor),
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: primaryTextColor),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => EditAccountBottomSheet(
                                viewModel: accountVM, account: account),
                          );
                          if (result != null) {
                            setState(() => _hasBeenUpdated = true);

                            if (!context.mounted) return;
                            final freshTx = context
                                .read<TransactionViewModel>()
                                .state
                                .transactions;
                            context
                                .read<AccountDetailsViewModel>()
                                .initialize(account, freshTx);
                          }
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, accountVM, account);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 10),
                              Text('Edit Account'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.error),
                              SizedBox(width: 10),
                              Text('Delete Account',
                                  style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 2. HERO CARD & SUMMARY PILLS
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thẻ Hero Card bốc số dư khả dụng real-time từ ví sống
                        AccountDetailHeroCard(account: account),
                        const SizedBox(height: AppSizes.md),
                        AccountDetailFilterCapsule(
                          activeRangeDisplay: activeRangeDisplay,
                          onPresetSelected: (label) => context
                              .read<AccountDetailsViewModel>()
                              .setFilter(label),
                          onCustomRangeTap: () async {
                            final DateTimeRange? range =
                                await showModalBottomSheet<DateTimeRange>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (sheetCtx) => AppCustomeDatePickerSheet(
                                initialRange: context
                                    .read<AccountDetailsViewModel>()
                                    .filterState
                                    .customDateRange,
                              ),
                            );
                            if (range != null) {
                              if (!context.mounted) return;
                              context.read<AccountDetailsViewModel>().setFilter(
                                  'Custom Range...',
                                  customRange: range);
                            }
                          },
                        ),
                        const SizedBox(height: AppSizes.md),
                        // Ô tổng Thu/Chi nạp dữ liệu sống tính toán trực tiếp
                        AccountDetailSummaryPills(
                          totalReceived: liveTotalReceived,
                          totalSpent: liveTotalSpent,
                        ),
                        const SizedBox(height: AppSizes.lg),
                      ],
                    ),
                  ),
                ),

                // 3. SEARCH BAR
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  sliver: SliverToBoxAdapter(
                    child: AppSearchBar(
                      controller: _searchController,
                      hintText: 'Search transactions...',
                      onChanged: (value) => context
                          .read<AccountDetailsViewModel>()
                          .setSearchQuery(value),
                    ),
                  ),
                ),

                // 4. TRANSACTION FEED
                AccountTransactionFeed(
                  transactions: liveFiltered,
                  categories:
                      context.watch<CategoryViewModel>().state.categories,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
