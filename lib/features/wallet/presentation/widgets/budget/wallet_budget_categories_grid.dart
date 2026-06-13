import 'package:flutter/material.dart';

import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/home/presentation/widgets/budget_categories/budget_category_card.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/shared/states/section_empty_state.dart';

class WalletBudgetCategoriesGrid extends StatelessWidget {
  final List<BudgetCategoryEntity> categories;
  final ValueChanged<BudgetCategoryEntity>? onTapCategory;

  const WalletBudgetCategoriesGrid({
    super.key,
    required this.categories,
    this.onTapCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SectionEmptyState(
        title: 'No Budget Categories',
        subtitle: 'Set up your budget categories to monitor spending.',
        icon: Icons.pie_chart_outline_rounded,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.md,
        mainAxisSpacing: AppSizes.md,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final entity = categories[index];

        return BudgetCategoryCard(
          category: entity,
          onTap: () {
            if (onTapCategory != null) {
              onTapCategory!(entity);
            }
          },
        );
      },
    );
  }
}
