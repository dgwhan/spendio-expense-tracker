import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class CategoryBudgetEmpty extends StatelessWidget {
  const CategoryBudgetEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Center(
        child: Column(
          children: [
            Text(
              'No Category Budgets Set',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Distribute your monthly budget into specific categories.',
              style: TextStyle(fontSize: 12, color: mutedTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
