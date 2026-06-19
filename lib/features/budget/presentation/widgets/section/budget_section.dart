import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import '../monthly/monthly_budget_card_container.dart';
import '../category/budget_categories_horizontal_list.dart';

class BudgetSection extends StatelessWidget {
  final double totalSpent;
  final double totalBudget;
  final int daysLeft;
  final List<BudgetCategoryProgressEntity> categories;
  final int userId;
  final VoidCallback? onCreateBudgetTap;
  final VoidCallback? onGetDetailBudgetTap;
  final VoidCallback? onCreateCategoryBudgetTap;

  const BudgetSection({
    super.key,
    required this.totalSpent,
    required this.totalBudget,
    required this.daysLeft,
    required this.categories,
    required this.userId,
    this.onCreateBudgetTap,
    this.onGetDetailBudgetTap,
    this.onCreateCategoryBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hasBudget = totalBudget > 0;
    final hasCategoryBudget = categories.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                ),
              ),
              IconButton(
                onPressed: hasBudget ? onGetDetailBudgetTap : onCreateBudgetTap,
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        MonthlyBudgetCardContainer(
          totalSpent: totalSpent,
          totalBudget: totalBudget,
          daysLeft: daysLeft,
          userId: userId,
        ),
        const SizedBox(height: AppSizes.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Budgets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                ),
              ),
              IconButton(
                onPressed: hasCategoryBudget
                    ? onGetDetailBudgetTap
                    : onCreateCategoryBudgetTap,
                icon: Icon(
                  hasCategoryBudget
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.add_circle_outline_rounded,
                  size: hasCategoryBudget ? 16 : 22,
                  color: hasCategoryBudget
                      ? (isDark ? Colors.grey[400] : Colors.grey[600])
                      : AppColors.primary,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        BudgetCategoriesHorizontalList(
          categories: categories,
          userId: userId,
        ),
      ],
    );
  }
}
