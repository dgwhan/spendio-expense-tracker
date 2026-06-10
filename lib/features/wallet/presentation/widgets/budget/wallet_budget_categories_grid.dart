import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/presentation/widgets/shared/dashboard_section_container.dart';
import 'package:spend_io_app/features/home/presentation/widgets/budget_categories/budget_category_card.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';

class WalletBudgetCategoriesGrid extends StatelessWidget {
  final List<BudgetCategoryEntity> categories;

  const WalletBudgetCategoriesGrid({
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
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.7,
            ),
            itemBuilder: (context, index) {
              final entity = categories[index];

              return BudgetCategoryCard(
                category: entity as dynamic,
              );
            },
          ),
        ),
      ],
    );
  }
}
