import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/dialogs/app_dialogs.dart';
import 'package:spend_io_app/core/widgets/input/app_search_bar.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/screen/edit_account_screen.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_details_header.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_metrics_section.dart';
import 'package:spend_io_app/shared/widgets/date_picker/app_custome_date_picker_sheet.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/account_transaction_feed.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_details_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/screen/utils/account_actions.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/filter/account_list_subheader.dart';

class AccountDetailsScreen extends StatelessWidget {
  final AccountEntity account;
  const AccountDetailsScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountDetailsViewModel>(
      create: (_) {
        return AccountDetailsViewModel();
      },
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
  State<_AccountDetailsScreenBody> createState() {
    return _AccountDetailsScreenBodyState();
  }
}

class _AccountDetailsScreenBodyState extends State<_AccountDetailsScreenBody> {
  bool _hasBeenUpdated = false;
  late final TextEditingController _searchController;
  final AccountSortOption _transactionSort = AccountSortOption.newest;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final String remoteUid = FirebaseAuth.instance.currentUser?.uid ?? '';

        context
            .read<TransactionViewModel>()
            .loadByAccount(widget.targetAccountId);
        context
            .read<AccountViewModel>()
            .loadAccounts(widget.initialAccount.userId, remoteUid);

        final allTransactions =
            context.read<TransactionViewModel>().state.transactions;
        context
            .read<AccountDetailsViewModel>()
            .initialize(widget.initialAccount, allTransactions);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    context.read<TransactionViewModel>().loadAllTransactions();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, AccountViewModel accountVM,
      AccountEntity account) async {
    final navigator = Navigator.of(context);

    final confirm = await AppDialogs.showDelete(
      context: context,
      title: 'Delete Account',
      content:
          'Are you sure you want to delete this account? This action cannot be undone.',
    );

    if (confirm == true && mounted) {
      final localId = account.userId;
      final String remoteUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await accountVM.deleteAccount(localId, remoteUid, account.id);

      if (mounted) {
        Future.microtask(() {
          navigator.pop(AccountDetailsAction.deleted);
        });
      }
    }
  }

  void _triggerEdit(BuildContext context, AccountViewModel accountVM,
      AccountEntity account) async {
    final detailsVM = context.read<AccountDetailsViewModel>();
    final txVM = context.read<TransactionViewModel>();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return EditAccountScreen(viewModel: accountVM, account: account);
        },
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _hasBeenUpdated = true;
      });
      final freshTx = txVM.state.transactions;
      detailsVM.initialize(account, freshTx);
    }
  }

  void _openCustomRangePicker(BuildContext context) async {
    final detailsVM = context.read<AccountDetailsViewModel>();

    final DateTimeRange? range = await showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return AppCustomeDatePickerSheet(
          initialRange: detailsVM.filterState.customDateRange,
        );
      },
    );

    if (range != null && mounted) {
      detailsVM.setFilter('Custom Range...', customRange: range);
    }
  }

  void _navigateBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Future.microtask(() {
        if (!context.mounted) {
          return;
        }

        final returnAction = _hasBeenUpdated
            ? AccountDetailsAction.updated
            : AccountDetailsAction.none;
        Navigator.pop(context, returnAction);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final accountVM = context.watch<AccountViewModel>();
    final txState = context.watch<TransactionViewModel>().state;
    final matches = accountVM.accounts.where((acc) {
      return acc.id == widget.targetAccountId;
    });

    if (matches.isEmpty && _hasBeenUpdated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final account = matches.isNotEmpty ? matches.first : widget.initialAccount;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<AccountDetailsViewModel>()
            .initialize(account, txState.transactions);
      }
    });

    final detailsVM = context.watch<AccountDetailsViewModel>();
    final filterState = detailsVM.filterState;
    final ledgerState = detailsVM.ledgerState;

    final List<TransactionEntity> liveFiltered = List.from(
      (ledgerState?.filteredTransactions != null)
          ? ledgerState!.filteredTransactions
          : [],
    );

    if (_transactionSort == AccountSortOption.newest) {
      liveFiltered.sort((a, b) {
        return b.transactionDate.compareTo(a.transactionDate);
      });
    } else if (_transactionSort == AccountSortOption.oldest) {
      liveFiltered.sort((a, b) {
        return a.transactionDate.compareTo(b.transactionDate);
      });
    }

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
        if (didPop) {
          return;
        }
        _navigateBack(context);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              final String remoteUid =
                  FirebaseAuth.instance.currentUser?.uid ?? '';
              await context
                  .read<AccountViewModel>()
                  .loadAccounts(account.userId, remoteUid, forceRefresh: true);
              if (!context.mounted) {
                return;
              }
              await context
                  .read<TransactionViewModel>()
                  .loadByAccount(widget.targetAccountId);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              slivers: [
                AccountDetailsHeader(
                  accountName: account.name,
                  balance: account.balance,
                  primaryTextColor: primaryTextColor,
                  onBackTap: () {
                    _navigateBack(context);
                  },
                  onEditTap: () {
                    _triggerEdit(context, accountVM, account);
                  },
                  onDeleteTap: () {
                    _showDeleteConfirmation(context, accountVM, account);
                  },
                ),
                AccountMetricsSection(
                  account: account,
                  activeRangeDisplay: activeRangeDisplay,
                  totalReceived: liveTotalReceived,
                  totalSpent: liveTotalSpent,
                  onPresetSelected: (label) {
                    context.read<AccountDetailsViewModel>().setFilter(label);
                  },
                  onCustomRangeTap: () {
                    _openCustomRangePicker(context);
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSearchBar(
                            controller: _searchController,
                            hintText: 'Search transactions...',
                            onChanged: (value) {
                              context
                                  .read<AccountDetailsViewModel>()
                                  .setSearchQuery(value);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),
                AccountTransactionFeed(
                  transactions: liveFiltered,
                  categories:
                      context.watch<CategoryViewModel>().state.categories,
                  selectedDatePreset:
                      filterState.activeRangeLabel == 'Custom Range...'
                          ? 'Custom'
                          : 'All',
                  customStartDate: filterState.customDateRange?.start,
                  customEndDate: filterState.customDateRange?.end,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
