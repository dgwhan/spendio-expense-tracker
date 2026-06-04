import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/shared/dashboard_section_container.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/budget_categories/budget_category_card.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/budget_category_model.dart';

class BudgetCategoriesGrid extends StatelessWidget {
  final List<BudgetCategoryModel> categories;

  const BudgetCategoriesGrid({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.textPrimaryLight,
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
              crossAxisCount: 2, //chia ra 2 cột
              mainAxisSpacing: 12, //khoảng cách hàng dọc
              crossAxisSpacing: 12, //khoảng cách hàng ngang
              childAspectRatio: 1.7, //tỷ lệ khung
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
