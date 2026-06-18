import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/presentation/widgets/shared/dashboard_section_container.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/budget_category_card.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart'; // SỬA: Import đúng Progress Entity

class BudgetCategoriesGrid extends StatelessWidget {
  final List<BudgetCategoryProgressEntity> categories;

  const BudgetCategoriesGrid({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            'Spending Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
          ),
        ),
        DashboardSectionContainer(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Chia ra 2 cột
              mainAxisSpacing: 12, // Khoảng cách hàng dọc
              crossAxisSpacing: 12, // Khoảng cách hàng ngang
              childAspectRatio: 1.7, // Tỷ lệ khung
            ),
            itemBuilder: (context, index) {
              return BudgetCategoryCard(category: categories[index]);
            },
          ),
        ),
      ],
    );
  }
}
