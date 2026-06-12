import 'package:flutter/material.dart';

import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/home/presentation/widgets/budget_categories/budget_category_card.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/shared/states/section_empty_state.dart';

class WalletBudgetCategoriesGrid extends StatelessWidget {
  final List<BudgetCategoryEntity> categories;

  const WalletBudgetCategoriesGrid({
    super.key,
    required this.categories,
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

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final entity = categories[index];

          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: SizedBox(
              width: 170,
              child: BudgetCategoryCard(
                category: entity as dynamic,
              ),
            ),
          );
        },
      ),
    );
  }
}
