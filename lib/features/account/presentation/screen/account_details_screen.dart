import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/transaction_grouping.dart';
import 'package:spend_io_app/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:spend_io_app/core/widgets/input/app_search_bar.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_details_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/screen/utils/account_actions.dart'; // Import Shared Enum
import 'package:spend_io_app/features/account/presentation/screen/widgets/account_filter_bottom_sheet.dart'; // Import Sheet

import 'package:spend_io_app/features/account/presentation/widgets/edit_account_bottom_sheet.dart';
import 'package:spend_io_app/features/account/presentation/widgets/widgets/hero/account_detail_hero_card.dart';
import 'package:spend_io_app/features/account/presentation/widgets/widgets/filter/account_detail_filter_capsule.dart';
import 'package:spend_io_app/features/account/presentation/widgets/widgets/transaction/account_detail_summary_pills.dart';
import 'package:spend_io_app/features/account/presentation/widgets/widgets/transaction/account_detail_transaction_tile.dart';

/// [App Location] Navigation Stack -> Account Details Screen.
/// [Core Function] Clean orchestrator managing structural views for individual wallet data pipelines.
class AccountDetailsScreen extends StatelessWidget {
  final AccountEntity account;
  const AccountDetailsScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountDetailsViewModel>(
      create: (_) {
        final vm = AccountDetailsViewModel();
        vm.initialize(account);
        return vm;
      },
      child: _AccountDetailsScreenBody(initialAccount: account),
    );
  }
}

class _AccountDetailsScreenBody extends StatefulWidget {
  final AccountEntity initialAccount;
  const _AccountDetailsScreenBody({required this.initialAccount});

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(
      BuildContext context, WalletViewModel walletVM, AccountEntity account) {
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
          walletVM.deleteAccount(account.id).then((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context, AccountDetailsAction.deleted);
            }
          });
        },
      ),
    );
  }

  String _formatGroupHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateZero = DateTime(date.year, date.month, date.day);
    final formatted = DateFormat('MMMM d').format(date).toUpperCase();

    if (dateZero.isAtSameMomentAs(today)) return 'TODAY - $formatted';
    if (dateZero.isAtSameMomentAs(yesterday)) return 'YESTERDAY - $formatted';
    return '${DateFormat('EEEE').format(date).toUpperCase()} - $formatted';
  }

  String _formatNetTotal(double net) {
    final formatted = CurrencyFormatter.format(net.abs());
    return net > 0 ? '+$formatted' : (net < 0 ? '-$formatted' : formatted);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final walletVM = context.watch<WalletViewModel>();
    final matches =
        walletVM.accounts.where((acc) => acc.id == widget.initialAccount.id);
    final account = matches.isNotEmpty ? matches.first : widget.initialAccount;

    final detailsVM = context.watch<AccountDetailsViewModel>();
    final filterState = detailsVM.filterState;
    final ledgerState = detailsVM.ledgerState;

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
                : AccountDetailsAction.none,
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
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
                title: Text(account.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: primaryTextColor)),
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
                              viewModel: walletVM, account: account),
                        );
                        if (result != null) {
                          setState(() => _hasBeenUpdated = true);
                          final upMatches = walletVM.accounts
                              .where((a) => a.id == account.id);
                          detailsVM.initialize(
                              upMatches.isNotEmpty ? upMatches.first : account);
                        }
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, walletVM, account);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Edit Account')
                          ])),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.error),
                            SizedBox(width: 10),
                            Text('Delete Account',
                                style: TextStyle(color: AppColors.error))
                          ])),
                    ],
                  ),
                ],
              ),

              // 2. HERO CARD & SUMMARY PILLS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountDetailHeroCard(account: account),
                      const SizedBox(height: AppSizes.md),
                      AccountDetailFilterCapsule(
                        activeRangeDisplay: activeRangeDisplay,
                        onTap: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (sheetCtx) =>
                              AccountFilterBottomSheet(detailsVM: detailsVM),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      if (ledgerState != null) ...[
                        AccountDetailSummaryPills(
                            totalReceived: ledgerState.totalReceived,
                            totalSpent: ledgerState.totalSpent),
                      ],
                      const SizedBox(height: AppSizes.lg),
                    ],
                  ),
                ),
              ),

              // 3. CLEAN CORE SEARCH BAR
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                sliver: SliverToBoxAdapter(
                  child: AppSearchBar(
                    controller: _searchController,
                    hintText: 'Search transactions...',
                    onChanged: (value) => detailsVM.setSearchQuery(value),
                  ),
                ),
              ),

              // 4. TRANSACTION FEED
              if (ledgerState == null) ...[
                const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator())),
              ] else if (ledgerState.dayGroups.isEmpty) ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 48,
                            color: mutedTextColor.withValues(alpha: 0.5)),
                        const SizedBox(height: AppSizes.md),
                        Text('No Transactions Found',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor)),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                            'Try modifying search keyword or active date range filter.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 13, color: mutedTextColor)),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                for (final TransactionDayGroup group
                    in ledgerState.dayGroups) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatGroupHeaderDate(group.date),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: mutedTextColor)),
                          Text(
                              _formatNetTotal(
                                  group.totalIncome - group.totalExpense),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (group.totalIncome -
                                              group.totalExpense) >=
                                          0
                                      ? AppColors.success
                                      : AppColors.error)),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          AccountDetailTransactionTile(tx: group.items[index]),
                      childCount: group.items.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
