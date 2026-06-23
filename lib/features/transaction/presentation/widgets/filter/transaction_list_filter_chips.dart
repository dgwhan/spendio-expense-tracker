import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/filter/filter_dropdown_row.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/filter/filter_type_row.dart';

class TransactionListFilterChips extends StatelessWidget {
  final TransactionType? selectedType;
  final CategoryEntity? selectedCategory;
  final AccountEntity? selectedAccount;
  final String selectedDatePreset;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final List<CategoryEntity> categories;
  final List<AccountEntity> accounts;
  final ValueChanged<TransactionType?> onTypeSelected;
  final ValueChanged<CategoryEntity?> onCategorySelected;
  final ValueChanged<AccountEntity?> onAccountSelected;
  final void Function(String preset, DateTime? start, DateTime? end)
      onDatePresetSelected;
  final VoidCallback onClearAll;

  const TransactionListFilterChips({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
    required this.selectedAccount,
    required this.selectedDatePreset,
    required this.customStartDate,
    required this.customEndDate,
    required this.categories,
    required this.accounts,
    required this.onTypeSelected,
    required this.onCategorySelected,
    required this.onAccountSelected,
    required this.onDatePresetSelected,
    required this.onClearAll,
  });

  bool get _hasActiveFilters {
    return selectedType != null ||
        selectedCategory != null ||
        selectedAccount != null ||
        selectedDatePreset != 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Kiểu giao dịch
          FilterTypeRow(
            selectedType: selectedType,
            hasActiveFilters: _hasActiveFilters,
            onTypeSelected: onTypeSelected,
            onClearAll: onClearAll,
          ),

          const SizedBox(height: 10),

          //Bộ lọc chuyên sâu dạng Dropdown
          FilterDropdownRow(
            selectedType: selectedType,
            selectedCategory: selectedCategory,
            selectedAccount: selectedAccount,
            selectedDatePreset: selectedDatePreset,
            customStartDate: customStartDate,
            customEndDate: customEndDate,
            categories: categories,
            accounts: accounts,
            onCategorySelected: onCategorySelected,
            onAccountSelected: onAccountSelected,
            onDatePresetSelected: onDatePresetSelected,
          ),
        ],
      ),
    );
  }
}
