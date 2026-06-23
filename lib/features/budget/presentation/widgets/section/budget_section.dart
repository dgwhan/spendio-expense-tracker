import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/category/budget_category_card.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/monthly/monthly_budget_card.dart';
import 'package:spend_io_app/core/widgets/common/app_circle_add_button.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_entity.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';

class BudgetSection extends StatelessWidget {
  final double totalSpent;
  final double totalBudget;
  final int daysLeft;
  final List<BudgetCategoryProgressEntity> categories;
  final int userId;
  final VoidCallback onCreateBudgetTap;
  final VoidCallback onGetDetailBudgetTap;
  final VoidCallback onCreateCategoryBudgetTap;

  final Function(
          BudgetCategoryEntity budgetCategory, CategoryEntity categoryDetails)
      onEditCategoryBudgetTap;

  const BudgetSection({
    super.key,
    required this.totalSpent,
    required this.totalBudget,
    required this.daysLeft,
    required this.categories,
    required this.userId,
    required this.onCreateBudgetTap,
    required this.onGetDetailBudgetTap,
    required this.onCreateCategoryBudgetTap,
    required this.onEditCategoryBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textMuted =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final currentMonthName = DateFormat('MMMM').format(DateTime.now());
    final remaining = totalBudget - totalSpent;
    final percentage =
        totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- TIÊU ĐỀ BUDGET THÁNG ---
        InkWell(
          onTap: onGetDetailBudgetTap,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentMonthName Budget',
                style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: textMuted,
                size: 18,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // --- HIỂN THỊ CARD TỔNG QUAN BUDGET THÁNG ---
        if (totalBudget <= 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'No Budget Set Yet',
                    style: AppTextStyles.cardTitle.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  TextButton(
                    onPressed: onCreateBudgetTap,
                    child: Text(
                      'Focus Monthly Budget',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          MonthlyBudgetCard(
            totalSpent: totalSpent,
            totalBudget: totalBudget,
            remaining: remaining,
            percentage: percentage,
            daysLeft: daysLeft,
            userId: userId,
            onTap: onGetDetailBudgetTap,
          ),
        ],

        const SizedBox(height: 24),

        // --- TIÊU ĐỀ SPENDING CATEGORIES ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spending Categories',
              style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
            ),
            AppCircleAddButton(
              onTap: onCreateCategoryBudgetTap,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),

        // --- DANH SÁCH DANH MỤC NGÂN SÁCH (LIST VIEW) ---
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No category budgets set',
                style: AppTextStyles.caption.copyWith(color: textMuted),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final progressItem = categories[index];
              final budgetCat = progressItem.budgetCategory;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  onEditCategoryBudgetTap(
                    budgetCat,
                    CategoryEntity(
                      id: budgetCat.categoryId,
                      userId: userId,
                      name: budgetCat.name,
                      type: 'expense',
                      groupName: 'Default',
                      iconCodePoint: 57937,
                      iconFontFamily: 'MaterialIcons',
                      colorValue: 0xFFF44336,
                    ),
                  );
                },
                child: BudgetCategoryCard(
                  progress: progressItem,
                  userId: userId,
                  cardType: BudgetCardType.horizontal,
                ),
              );
            },
          ),
      ],
    );
  }
}
