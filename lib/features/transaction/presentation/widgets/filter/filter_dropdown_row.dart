import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/filter/category_picker_sheet.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/filter/wallet_picker_sheet.dart';
import 'package:spend_io_app/shared/widgets/date_picker/app_custome_date_picker_sheet.dart';

class FilterDropdownRow extends StatelessWidget {
  final TransactionType? selectedType;
  final CategoryEntity? selectedCategory;
  final AccountEntity? selectedAccount;
  final String selectedDatePreset;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final List<CategoryEntity> categories;
  final List<AccountEntity> accounts;
  final ValueChanged<CategoryEntity?> onCategorySelected;
  final ValueChanged<AccountEntity?> onAccountSelected;
  final void Function(String preset, DateTime? start, DateTime? end)
      onDatePresetSelected;

  const FilterDropdownRow({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
    required this.selectedAccount,
    required this.selectedDatePreset,
    required this.customStartDate,
    required this.customEndDate,
    required this.categories,
    required this.accounts,
    required this.onCategorySelected,
    required this.onAccountSelected,
    required this.onDatePresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildInputChip(
            context,
            label: selectedAccount != null
                ? selectedAccount!.name
                : AppLocalizations.translate('all_wallets'),
            isActive: selectedAccount != null,
            onPressed: () {
              _showWalletPickerSheet(context);
            },
            onDeleted: selectedAccount != null
                ? () {
                    onAccountSelected(null);
                  }
                : null,
          ),
          _buildInputChip(
            context,
            label: selectedCategory?.name ??
                AppLocalizations.translate('categories'),
            isActive: selectedCategory != null,
            onPressed: () {
              _showCategoryPickerSheet(context);
            },
            onDeleted: selectedCategory != null
                ? () {
                    onCategorySelected(null);
                  }
                : null,
          ),
          _buildInputChip(
            context,
            label: _getDateLabelText(),
            isActive: selectedDatePreset != 'All',
            onPressed: () {
              _showDatePresetSheet(context);
            },
            onDeleted: selectedDatePreset != 'All'
                ? () {
                    onDatePresetSelected('All', null, null);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInputChip(BuildContext context,
      {required String label,
      required bool isActive,
      required VoidCallback onPressed,
      VoidCallback? onDeleted}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InputChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.buttonLabel.copyWith(
                  fontSize: 12,
                  color: isActive
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF2D3748)),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onDeleted == null) ...{
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 14, color: Color(0xFF718096)),
            },
          ],
        ),
        onPressed: onPressed,
        onDeleted: onDeleted,
        backgroundColor: fillColor,
        selected: isActive,
        selectedColor: isDark
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.08),
        checkmarkColor: AppColors.primary,
        deleteIconColor: AppColors.primary,
        showCheckmark: false,
       
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
        selectedShadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
              color: Colors.transparent, width: 0, style: BorderStyle.none),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      ),
    );
  }

  String _getDateLabelText() {
    if (selectedDatePreset == 'All') {
      return AppLocalizations.translate('last_30_days');
    }
    if (selectedDatePreset == 'Today') {
      return AppLocalizations.translate('today');
    }
    if (selectedDatePreset == 'This Week') {
      return AppLocalizations.translate('this_week');
    }
    if (selectedDatePreset == 'This Month') {
      return AppLocalizations.translate('this_month');
    }
    if (selectedDatePreset == 'Custom' &&
        customStartDate != null &&
        customEndDate != null) {
      return "${DateFormat('dd/MM').format(customStartDate!)} - ${DateFormat('dd/MM').format(customEndDate!)}";
    }
    return selectedDatePreset;
  }

  void _showWalletPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return WalletPickerSheet(
            accounts: accounts,
            selectedAccount: selectedAccount,
            onAccountSelected: onAccountSelected);
      },
    );
  }

  void _showCategoryPickerSheet(BuildContext context) {
    final displayCategories = selectedType == null
        ? categories
        : categories.where((c) {
            return c.type == selectedType!.name;
          }).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CategoryPickerSheet(
            categories: displayCategories,
            selectedCategory: selectedCategory,
            onCategorySelected: (cat) {
              onCategorySelected(cat as CategoryEntity);
            });
      },
    );
  }

  void _showDatePresetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md, vertical: 16),
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
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(AppLocalizations.translate('select_date_range'),
                      style: AppTextStyles.headingMedium),
                  const SizedBox(height: AppSizes.sm),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        'All',
                        'Today',
                        'This Week',
                        'This Month',
                        'Custom'
                      ].map((preset) {
                        final isSelected = selectedDatePreset == preset;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(preset == 'All' ? 'Last 30 Days' : preset,
                              style: AppTextStyles.bodyNormal.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      isSelected ? AppColors.primary : null)),
                          trailing: isSelected
                              ? const Icon(Icons.check,
                                  color: AppColors.primary, size: 20)
                              : null,
                          onTap: () {
                            _handleDatePresetTap(context, preset);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleDatePresetTap(BuildContext context, String preset) async {
    Navigator.pop(context);
    if (preset == 'Custom') {
      final DateTimeRange? initialRange =
          (customStartDate != null && customEndDate != null)
              ? DateTimeRange(start: customStartDate!, end: customEndDate!)
              : null;

      final picked = await showModalBottomSheet<DateTimeRange>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) {
          return AppCustomeDatePickerSheet(initialRange: initialRange);
        },
      );

      if (picked != null) {
        onDatePresetSelected('Custom', picked.start, picked.end);
      }
    } else {
      onDatePresetSelected(preset, null, null);
    }
  }
}
