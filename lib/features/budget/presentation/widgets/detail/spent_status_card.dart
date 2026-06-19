import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';

class SpentStatusCard extends StatelessWidget {
  final BudgetCategoryProgressEntity progress;
  final bool isDark;

  const SpentStatusCard({
    super.key,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final isOverBudget = progress.remaining < 0;
    final alertColor = isOverBudget ? AppColors.error : AppColors.success;
    final percentage = (progress.percentage / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowNatural2,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'Spent Status',
            style: TextStyle(fontSize: 14, color: secondaryTextColor),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            formatCurrency(progress.spent),
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryTextColor),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'of ${formatCurrency(progress.budgetCategory.amount)} limit',
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
          const SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: isDark
                  ? AppColors.surfaceSecondaryDark
                  : AppColors.surfaceSecondaryLight,
              valueColor: AlwaysStoppedAnimation<Color>(alertColor),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: alertColor),
              ),
              Text(
                isOverBudget
                    ? 'Over by ${formatCurrency(progress.remaining.abs())}'
                    : '${formatCurrency(progress.remaining)} left',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: alertColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
