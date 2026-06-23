import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

class TransactionTypeSegment extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeSegment({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceSecondaryDark : const Color(0xFFF4F5F7);
    final isExpense = selectedType == TransactionType.expense;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double tabWidth = (totalWidth - 8) /
            2; 

        return Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                left: isExpense ? 0 : tabWidth,
                width: tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1D24) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                ),
              ),

              // LỚP CHỮ HIỂN THỊ ĐÈ LÊN TRÊN KHỐI TRƯỢT
              Row(
                children: [
                  // Tab 1: Expense
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        onTypeChanged(TransactionType.expense);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: AppTextStyles.percentIndicator.copyWith(
                            color: isExpense
                                ? AppColors.expense
                                : (isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight),
                            fontWeight:
                                isExpense ? FontWeight.bold : FontWeight.w600,
                          ),
                          child: Text(AppLocalizations.translate('Expense')),
                        ),
                      ),
                    ),
                  ),

                  // Tab 2: Income
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        onTypeChanged(TransactionType.income);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: AppTextStyles.percentIndicator.copyWith(
                            color: !isExpense
                                ? AppColors.income
                                : (isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight),
                            fontWeight:
                                !isExpense ? FontWeight.bold : FontWeight.w600,
                          ),
                          child: Text(AppLocalizations.translate('Income')),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
