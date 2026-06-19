import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class EmptyMonthlyBudgetCard extends StatelessWidget {
  const EmptyMonthlyBudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      padding: const EdgeInsets.symmetric(
          vertical: AppSizes.xl, horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.add_chart_rounded, size: 40, color: mutedTextColor),
            const SizedBox(height: AppSizes.sm),
            Text(
              'No Active Monthly Budget',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Set up your spending limit to track expenses.',
              style: TextStyle(fontSize: 13, color: mutedTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
