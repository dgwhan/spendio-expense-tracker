import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'budget_categories_horizontal_list.dart';
import 'budget_category_loading.dart';
import 'category_budget_empty.dart';

class BudgetCategoryContainer extends StatelessWidget {
  final int userId;
  const BudgetCategoryContainer({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.watch<BudgetCategoryViewModel>();

    if (categoryVM.isLoading && categoryVM.progressList.isEmpty) {
      return const BudgetCategoryLoading(height: 180);
    }

    if (categoryVM.progressList.isEmpty) {
      return const CategoryBudgetEmpty();
    }

    return BudgetCategoriesHorizontalList(
      categories: categoryVM.progressList,
      userId: userId,
    );
  }
}
