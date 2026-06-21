import 'package:flutter/material.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'budget_category_card.dart';
import 'category_budget_empty.dart';

class BudgetCategoriesHorizontalList extends StatelessWidget {
  final List<BudgetCategoryProgressEntity> categories;
  final int userId;

  const BudgetCategoriesHorizontalList({
    super.key,
    required this.categories,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const CategoryBudgetEmpty();
    }

    return SizedBox(
      height: 132,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.42,
            margin: EdgeInsets.only(
              right: index == categories.length - 1 ? 0 : 12,
            ),
            child: BudgetCategoryCard(
              progress: categories[index],
              userId: userId,
              cardType: BudgetCardType.vertical,
            ),
          );
        },
      ),
    );
  }
}
