import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/transaction_grouping.dart';
import 'package:spend_io_app/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:spend_io_app/features/home/data/models/recent_transaction_model.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/account_details_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/add_transaction_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/edit_account_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/widgets/hero/account_detail_hero_card.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/widgets/filter/account_detail_filter_capsule.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/widgets/transaction/account_detail_summary_pills.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/widgets/transaction/account_detail_transaction_tile.dart';

enum AccountDetailsAction {
  updated,
  deleted,
  none,
}

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
  State<_AccountDetailsScreenBody> createState() => _AccountDetailsScreenBodyState();
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

  void _showDeleteConfirmation(BuildContext context, WalletViewModel walletVM, AccountEntity account) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AppConfirmationDialog(
          title: 'Delete Account',
          content: 'Are you sure you want to delete this account? This action cannot be undone.',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
          isDestructive: true,
          onConfirm: () {
            Navigator.pop(dialogCtx);
            walletVM.deleteAccount(account.id).then((_) {
              if (context.mounted) {
                Navigator.pop(context, AccountDetailsAction.deleted);
              }
            });
          },
        );
      },
    );
  }

  void _openFilterSelector(BuildContext context, AccountDetailsViewModel detailsVM) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.cardRadiusLg),
              topRight: Radius.circular(AppRadius.cardRadiusLg),
            ),
          ),
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Active Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.5,
                children: [
                  _buildQuickFilterOption(sheetCtx, detailsVM, 'Last 30 Days'),
                  _buildQuickFilterOption(sheetCtx, detailsVM, 'Today'),
                  _buildQuickFilterOption(sheetCtx, detailsVM, 'This Month'),
                  _buildQuickFilterOption(sheetCtx, detailsVM, 'Last Month'),
                  _buildQuickFilterOption(sheetCtx, detailsVM, 'This Year'),
                  _buildQuickFilterOption(sheetCtx, detailsVM, 'Custom Range...', isCustomTrigger: true),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickFilterOption(
    BuildContext context, 
    AccountDetailsViewModel detailsVM, 
    String label, 
    {bool isCustomTrigger = false}
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight;
    final isSelected = detailsVM.filterState.activeRangeLabel == label;

    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        
        if (isCustomTrigger) {
          final DateTimeRange? range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialDateRange: detailsVM.filterState.customDateRange,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.primary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (range != null) {
            detailsVM.setFilter('Custom Range...', customRange: range);
          }
        } else {
          detailsVM.setFilter(label);
        }
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : inactiveColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? activeColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }

  String _formatGroupHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateZero = DateTime(date.year, date.month, date.day);
    
    final formatted = DateFormat('MMMM d').format(date).toUpperCase();
    if (dateZero.isAtSameMomentAs(today)) {
      return 'TODAY - $formatted';
    } else if (dateZero.isAtSameMomentAs(yesterday)) {
      return 'YESTERDAY - $formatted';
    } else {
      final dayName = DateFormat('EEEE').format(date).toUpperCase();
      return '$dayName - $formatted';
    }
  }

  String _formatNetTotal(double net) {
    final formatted = CurrencyFormatter.format(net.abs());
    if (net > 0) {
      return '+$formatted';
    } else if (net < 0) {
      return '-$formatted';
    } else {
      return formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final walletVM = context.watch<WalletViewModel>();
    final matches = walletVM.accounts.where((acc) {
      return acc.id == widget.initialAccount.id;
    });
    final account = matches.isNotEmpty ? matches.first : widget.initialAccount;

    final detailsVM = context.watch<AccountDetailsViewModel>();
    final filterState = detailsVM.filterState;
    final ledgerState = detailsVM.ledgerState;

    String activeRangeDisplay = filterState.activeRangeLabel;
    if (activeRangeDisplay == 'Custom Range...' && filterState.customDateRange != null) {
      final range = filterState.customDateRange!;
      final startFormatted = DateFormat('MMM d').format(range.start);
      final endFormatted = DateFormat('MMM d, yyyy').format(range.end);
      activeRangeDisplay = '$startFormatted - $endFormatted';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.pop(
          context, 
          _hasBeenUpdated ? AccountDetailsAction.updated : AccountDetailsAction.none
        );
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryTextColor,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context, 
                      _hasBeenUpdated ? AccountDetailsAction.updated : AccountDetailsAction.none
                    );
                  },
                ),
                title: Text(
                  account.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: primaryTextColor),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final detailsVM = context.read<AccountDetailsViewModel>();
                        final result = await showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          backgroundColor: AppColors.transparent,
                          builder: (_) => EditAccountBottomSheet(
                            viewModel: walletVM,
                            account: account,
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _hasBeenUpdated = true;
                          });
                          final upMatches = walletVM.accounts.where((a) {
                            return a.id == account.id;
                          });
                          final updatedAcc = upMatches.isNotEmpty ? upMatches.first : account;
                          detailsVM.initialize(updatedAcc);
                        }
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, walletVM, account);
                      }
                    },
                    itemBuilder: (context) {
                      return [
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
                              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                              SizedBox(width: 10),
                              Text('Delete Account', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
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
                        onTap: () {
                          _openFilterSelector(context, detailsVM);
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      if (ledgerState != null) ...[
                        AccountDetailSummaryPills(
                          totalReceived: ledgerState.totalReceived,
                          totalSpent: ledgerState.totalSpent,
                        ),
                      ],
                      const SizedBox(height: AppSizes.lg),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: primaryTextColor),
                      onChanged: (value) {
                        detailsVM.setSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.search,
                          color: mutedTextColor,
                        ),
                        hintText: 'Search transactions...',
                        hintStyle: TextStyle(
                          color: mutedTextColor.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (ledgerState == null) ...[
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ] else if (ledgerState.dayGroups.isEmpty) ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: mutedTextColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'No Transactions Found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          'Try modifying search keyword or active date range filter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: mutedTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                for (final TransactionDayGroup group in ledgerState.dayGroups) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatGroupHeaderDate(group.date),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: mutedTextColor,
                            ),
                          ),
                          Text(
                            _formatNetTotal(group.totalIncome - group.totalExpense),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: (group.totalIncome - group.totalExpense) >= 0 ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = group.items[index];
                        return AccountDetailTransactionTile(tx: tx);
                      },
                      childCount: group.items.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final tx = await showModalBottomSheet<RecentTransactionModel>(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: AppColors.transparent,
              builder: (_) => AddTransactionBottomSheet(account: account),
            );

            if (tx != null) {
              detailsVM.addTransaction(tx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${tx.title}" of ${CurrencyFormatter.format(tx.amount)} successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            }
          },
          backgroundColor: AppColors.primary,
          child: const Icon(
            Icons.add,
            color: AppColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
