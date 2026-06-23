import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/account_transaction_feed.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/category_picker_sheet.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/wallet_picker_sheet.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  TransactionType? _selectedType;
  CategoryEntity? _selectedCategory;
  AccountEntity? _selectedAccount;
  
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
    });
  }

  void _showCategoryPicker(List<CategoryEntity> categories) {
    final displayCategories = _selectedType == null
        ? categories
        : categories.where((c) => c.type == _selectedType!.name).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerSheet(
        categories: displayCategories,
        selectedCategory: _selectedCategory,
        onCategorySelected: (cat) {
          setState(() {
            _selectedCategory = cat as CategoryEntity;
          });
        },
      ),
    );
  }

  void _showWalletPicker(List<AccountEntity> accounts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => WalletPickerSheet(
        accounts: accounts,
        selectedAccount: _selectedAccount,
        onAccountSelected: (acc) {
          setState(() {
            _selectedAccount = acc;
          });
        },
      ),
    );
  }

  void _showDateRangePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.translate('select_date_range'),
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 16),
              _buildDateOption(context, 'All', AppLocalizations.translate('all')),
              _buildDateOption(context, 'Today', AppLocalizations.translate('today')),
              _buildDateOption(context, 'This Week', AppLocalizations.translate('this_week')),
              _buildDateOption(context, 'This Month', AppLocalizations.translate('this_month')),
              _buildDateOption(context, 'Custom', AppLocalizations.translate('custom_range')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateOption(BuildContext context, String preset, String label) {
    final isSelected = _selectedDatePreset == preset;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () async {
        Navigator.pop(context);
        if (preset == 'Custom') {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDateRange: _customStartDate != null && _customEndDate != null
                ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
                : null,
            builder: (context, child) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: isDark
                      ? const ColorScheme.dark(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          surface: AppColors.backgroundDark,
                          onSurface: Colors.white,
                        )
                      : const ColorScheme.light(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          surface: AppColors.backgroundLight,
                          onSurface: Colors.black,
                        ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              _selectedDatePreset = 'Custom';
              _customStartDate = picked.start;
              _customEndDate = picked.end;
            });
          }
        } else {
          setState(() {
            _selectedDatePreset = preset;
            _customStartDate = null;
            _customEndDate = null;
          });
        }
      },
    );
  }

  String _getDateFilterLabel() {
    final prefix = AppLocalizations.translate('filter_date').replaceAll(': {date}', '');
    if (_selectedDatePreset == 'All') {
      final label = AppLocalizations.translate('all');
      return '$prefix: $label';
    }
    if (_selectedDatePreset == 'Today') {
      final label = AppLocalizations.translate('today');
      return '$prefix: $label';
    }
    if (_selectedDatePreset == 'This Week') {
      final label = AppLocalizations.translate('this_week');
      return '$prefix: $label';
    }
    if (_selectedDatePreset == 'This Month') {
      final label = AppLocalizations.translate('this_month');
      return '$prefix: $label';
    }
    if (_selectedDatePreset == 'Custom') {
      if (_customStartDate != null && _customEndDate != null) {
        final startStr = DateFormat('dd/MM').format(_customStartDate!);
        final endStr = DateFormat('dd/MM').format(_customEndDate!);
        return '$startStr - $endStr';
      }
      return AppLocalizations.translate('custom_range');
    }
    return _selectedDatePreset;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txVM = context.watch<TransactionViewModel>();
    final catVM = context.watch<CategoryViewModel>();
    final accVM = context.watch<AccountViewModel>();

    final categories = catVM.state.categories;
    final accounts = accVM.accounts;
    final allTransactions = txVM.state.transactions;

    String getCategoryName(String categoryId) {
      try {
        return categories.firstWhere((c) => c.id == categoryId).name;
      } catch (_) {
        return categoryId;
      }
    }

    // Apply filtering logic
    final filteredTransactions = allTransactions.where((tx) {
      if (_searchQuery.isNotEmpty) {
        final note = tx.note?.toLowerCase() ?? '';
        final categoryName = getCategoryName(tx.categoryId).toLowerCase();
        if (!note.contains(_searchQuery.toLowerCase()) && !categoryName.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      if (_selectedType != null) {
        if (tx.type != _selectedType) {
          return false;
        }
      }

      if (_selectedCategory != null) {
        if (tx.categoryId != _selectedCategory!.id) {
          return false;
        }
      }

      if (_selectedAccount != null) {
        if (tx.accountId != _selectedAccount!.id) {
          return false;
        }
      }

      final txDate = tx.transactionDate;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

      if (_selectedDatePreset == 'Today') {
        if (txDate.isBefore(todayStart) || txDate.isAfter(todayEnd)) {
          return false;
        }
      } else if (_selectedDatePreset == 'This Week') {
        final daysToSubtract = now.weekday - 1;
        final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
        if (txDate.isBefore(weekStart)) {
          return false;
        }
      } else if (_selectedDatePreset == 'This Month') {
        final monthStart = DateTime(now.year, now.month, 1);
        if (txDate.isBefore(monthStart)) {
          return false;
        }
      } else if (_selectedDatePreset == 'Custom') {
        if (_customStartDate != null) {
          final start = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
          if (txDate.isBefore(start)) {
            return false;
          }
        }
        if (_customEndDate != null) {
          final end = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day, 23, 59, 59, 999);
          if (txDate.isAfter(end)) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final fillCol = isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight;

    final hasActiveFilters = _selectedType != null ||
        _selectedCategory != null ||
        _selectedAccount != null ||
        _selectedDatePreset != 'All' ||
        _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
        title: AppLocalizations.translate('all_transactions'),
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.translate('search_transactions'),
                  hintStyle: AppTextStyles.bodyNormal.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: fillCol,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Horizontal Filter Chips
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Type Chips: All
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(AppLocalizations.translate('all')),
                      selected: _selectedType == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = null;
                          _selectedCategory = null;
                        });
                      },
                      backgroundColor: fillCol,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedType == null ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: _selectedType == null ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                    ),
                  ),

                  // Type Chips: Expense
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(AppLocalizations.translate('expense')),
                      selected: _selectedType == TransactionType.expense,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = TransactionType.expense;
                          _selectedCategory = null;
                        });
                      },
                      backgroundColor: fillCol,
                      selectedColor: AppColors.expense,
                      labelStyle: TextStyle(
                        color: _selectedType == TransactionType.expense ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: _selectedType == TransactionType.expense ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                    ),
                  ),

                  // Type Chips: Income
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Text(AppLocalizations.translate('income')),
                      selected: _selectedType == TransactionType.income,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = TransactionType.income;
                          _selectedCategory = null;
                        });
                      },
                      backgroundColor: fillCol,
                      selectedColor: AppColors.income,
                      labelStyle: TextStyle(
                        color: _selectedType == TransactionType.income ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: _selectedType == TransactionType.income ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                    ),
                  ),

                  // Wallet Chip
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InputChip(
                      label: Text(_selectedAccount?.name ?? AppLocalizations.translate('wallet')),
                      onPressed: () => _showWalletPicker(accounts),
                      backgroundColor: _selectedAccount != null ? AppColors.primary.withValues(alpha: 0.15) : fillCol,
                      selected: _selectedAccount != null,
                      selectedColor: AppColors.primary.withValues(alpha: 0.25),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedAccount != null ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: _selectedAccount != null ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: _selectedAccount != null ? const BorderSide(color: AppColors.primary) : BorderSide.none,
                      ),
                      onDeleted: _selectedAccount != null
                          ? () {
                              setState(() {
                                _selectedAccount = null;
                              });
                            }
                          : null,
                      deleteIconColor: AppColors.primary,
                    ),
                  ),

                  // Category Chip
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InputChip(
                      label: Text(_selectedCategory?.name ?? AppLocalizations.translate('filter_category').replaceAll(': {category}', '')),
                      onPressed: () => _showCategoryPicker(categories),
                      backgroundColor: _selectedCategory != null ? AppColors.primary.withValues(alpha: 0.15) : fillCol,
                      selected: _selectedCategory != null,
                      selectedColor: AppColors.primary.withValues(alpha: 0.25),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedCategory != null ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: _selectedCategory != null ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: _selectedCategory != null ? const BorderSide(color: AppColors.primary) : BorderSide.none,
                      ),
                      onDeleted: _selectedCategory != null
                          ? () {
                              setState(() {
                                _selectedCategory = null;
                              });
                            }
                          : null,
                      deleteIconColor: AppColors.primary,
                    ),
                  ),

                  // Date range Chip
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InputChip(
                      label: Text(_getDateFilterLabel()),
                      onPressed: _showDateRangePickerSheet,
                      backgroundColor: _selectedDatePreset != 'All' ? AppColors.primary.withValues(alpha: 0.15) : fillCol,
                      selected: _selectedDatePreset != 'All',
                      selectedColor: AppColors.primary.withValues(alpha: 0.25),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedDatePreset != 'All' ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: _selectedDatePreset != 'All' ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: _selectedDatePreset != 'All' ? const BorderSide(color: AppColors.primary) : BorderSide.none,
                      ),
                      onDeleted: _selectedDatePreset != 'All'
                          ? () {
                              setState(() {
                                _selectedDatePreset = 'All';
                                _customStartDate = null;
                                _customEndDate = null;
                              });
                            }
                          : null,
                      deleteIconColor: AppColors.primary,
                    ),
                  ),

                  // Clear Filters button
                  if (hasActiveFilters)
                    TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.error),
                      label: Text(
                        AppLocalizations.translate('clear_filters'),
                        style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Transactions Feed List
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  AccountTransactionFeed(
                    transactions: filteredTransactions,
                    categories: categories,
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
