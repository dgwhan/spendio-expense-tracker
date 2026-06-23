import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

class FilterTypeRow extends StatelessWidget {
  final TransactionType? selectedType;
  final bool hasActiveFilters;
  final ValueChanged<TransactionType?> onTypeSelected;
  final VoidCallback onClearAll;

  const FilterTypeRow({
    super.key,
    required this.selectedType,
    required this.hasActiveFilters,
    required this.onTypeSelected,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChoiceChip(
              context, AppLocalizations.translate('all'), selectedType == null,
              () {
            onTypeSelected(null);
          }),
          _buildChoiceChip(context, AppLocalizations.translate('expense'),
              selectedType == TransactionType.expense, () {
            onTypeSelected(TransactionType.expense);
          }),
          _buildChoiceChip(context, AppLocalizations.translate('income'),
              selectedType == TransactionType.income, () {
            onTypeSelected(TransactionType.income);
          }),
          if (hasActiveFilters) ...{
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: ActionChip(
                onPressed: onClearAll,
                backgroundColor: AppColors.error.withValues(alpha: 0.08),
                avatar: const Icon(Icons.refresh_rounded,
                    size: 14, color: AppColors.error),
                label: Text(
                  AppLocalizations.translate('clear_filters'),
                  style: AppTextStyles.buttonLabel.copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                elevation: 0,
                pressElevation: 0,
                // SỬA TẠI ĐÂY: Triệt tiêu viền ẩn Material 3 cho ActionChip
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  side: const BorderSide(
                      color: Colors.transparent,
                      width: 0,
                      style: BorderStyle.none),
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          },
        ],
      ),
    );
  }

  Widget _buildChoiceChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg =
        isDark ? AppColors.surfaceDark : const Color(0xFFF4F5F7);
    final selectedBg = isDark ? AppColors.primary : const Color(0xFF0046E5);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(label),
        ),
        selected: isSelected,
        onSelected: (_) {
          onTap();
        },
        backgroundColor: unselectedBg,
        selectedColor: selectedBg,
        // SỬA TẠI ĐÂY: Xóa sạch bóng mờ lúc unselect lẫn khi bấm giữ
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
        selectedShadowColor: Colors.transparent,
        labelStyle: AppTextStyles.buttonLabel.copyWith(
          fontSize: 12,
          color: isSelected
              ? Colors.white
              : (isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF4A5568)),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(
              color: Colors.transparent, width: 0, style: BorderStyle.none),
        ),
        showCheckmark: false,
      ),
    );
  }
}
