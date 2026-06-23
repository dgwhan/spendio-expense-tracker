import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/input/app_search_bar.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/account_transaction_feed.dart';
import 'package:spend_io_app/features/account/presentation/widgets/filter/account_list_subheader.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/filter/transaction_list_filter_chips.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() {
    return _TransactionListScreenState();
  }
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  TransactionType? _selectedType;
  CategoryEntity? _selectedCategory;
  AccountEntity? _selectedAccount;

  AccountSortOption _currentSort = AccountSortOption.newest;
  String _selectedDatePreset = 'All';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadAllTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedType = null;
      _selectedCategory = null;
      _selectedAccount = null;
      _selectedDatePreset = 'All';
      _customStartDate = null;
      _customEndDate = null;
      _currentSort = AccountSortOption.newest;
    });
  }

  List<TransactionEntity> _getFilteredAndSortedTransactions(
    List<TransactionEntity> allTransactions,
    List<CategoryEntity> categories,
  ) {
    final filtered = allTransactions.where((tx) {
      if (_searchQuery.isNotEmpty) {
        final note = tx.note?.toLowerCase() ?? '';
        final catName = categories.any((c) {
          return c.id == tx.categoryId;
        })
            ? categories
                .firstWhere((c) {
                  return c.id == tx.categoryId;
                })
                .name
                .toLowerCase()
            : tx.categoryId.toLowerCase();
        if (!note.contains(_searchQuery.toLowerCase()) &&
            !catName.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      if (_selectedType != null && tx.type != _selectedType) {
        return false;
      }
      if (_selectedCategory != null && tx.categoryId != _selectedCategory!.id) {
        return false;
      }
      if (_selectedAccount != null && tx.accountId != _selectedAccount!.id) {
        return false;
      }

      final txDate = tx.transactionDate;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(microseconds: 1));

      if (_selectedDatePreset == 'Today') {
        if (txDate.isBefore(todayStart) || txDate.isAfter(todayEnd)) {
          return false;
        }
      } else if (_selectedDatePreset == 'This Week') {
        final weekStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        if (txDate.isBefore(weekStart)) {
          return false;
        }
      } else if (_selectedDatePreset == 'This Month') {
        final monthStart = DateTime(now.year, now.month, 1);
        if (txDate.isBefore(monthStart)) {
          return false;
        }
      } else if (_selectedDatePreset == 'Custom') {
        if (_customStartDate != null &&
            txDate.isBefore(DateTime(_customStartDate!.year,
                _customStartDate!.month, _customStartDate!.day))) {
          return false;
        }
        if (_customEndDate != null &&
            txDate.isAfter(DateTime(_customEndDate!.year, _customEndDate!.month,
                _customEndDate!.day, 23, 59, 59, 999))) {
          return false;
        }
      }

      return true;
    }).toList();

    switch (_currentSort) {
      case AccountSortOption.newest:
        filtered.sort((a, b) {
          return b.transactionDate.compareTo(a.transactionDate);
        });
        break;
      case AccountSortOption.oldest:
        filtered.sort((a, b) {
          return a.transactionDate.compareTo(b.transactionDate);
        });
        break;
      default:
        filtered.sort((a, b) {
          return b.transactionDate.compareTo(a.transactionDate);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txVM = context.watch<TransactionViewModel>();
    final catVM = context.watch<CategoryViewModel>();
    final accVM = context.watch<AccountViewModel>();

    final categories = catVM.state.categories;
    final accounts = accVM.accounts;
    final filteredTransactions =
        _getFilteredAndSortedTransactions(txVM.state.transactions, categories);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppHeader(
        title: AppLocalizations.translate('all_transactions'),
        showBack: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(AppSizes.md, 12, AppSizes.md, 6),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchBar(
                      controller: _searchController,
                      hintText:
                          AppLocalizations.translate('search_transactions'),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      onClear: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                ],
              ),
            ),
            TransactionListFilterChips(
              selectedType: _selectedType,
              selectedCategory: _selectedCategory,
              selectedAccount: _selectedAccount,
              selectedDatePreset: _selectedDatePreset,
              customStartDate: _customStartDate,
              customEndDate: _customEndDate,
              categories: categories,
              accounts: accounts,
              onTypeSelected: (type) {
                setState(() {
                  _selectedType = type;
                  _selectedCategory = null;
                });
              },
              onCategorySelected: (cat) {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              onAccountSelected: (acc) {
                setState(() {
                  _selectedAccount = acc;
                });
              },
              onDatePresetSelected: (preset, start, end) {
                setState(() {
                  _selectedDatePreset = preset;
                  _customStartDate = start;
                  _customEndDate = end;
                });
              },
              onClearAll: _clearAllFilters,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  AccountTransactionFeed(
                    transactions: filteredTransactions,
                    categories: categories,
                    selectedType: _selectedType,
                    selectedCategory: _selectedCategory,
                    selectedAccount: _selectedAccount,
                    selectedDatePreset: _selectedDatePreset,
                    customStartDate: _customStartDate,
                    customEndDate: _customEndDate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
