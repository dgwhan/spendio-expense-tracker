import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
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
      // Chieu cao bọc lay chieu cao mong muon cua BudgetCategoryCard (vi du mainAxisExtent cu la 140)
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // Tu dong tinh toan phan dem dau-cuoi mượt mà, khong bi gap layout khi cuon sat mep màn hình
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            // Cố định chiều rộng cho mỗi Card khi kéo ngang
            width: MediaQuery.of(context).size.width * 0.42,
            margin: EdgeInsets.only(
              // Nhét khoảng cách giữa các Card, phần tử cuối cùng không cần khoảng đệm phải
              right: index == categories.length - 1 ? 0 : AppSizes.md,
            ),
            child: BudgetCategoryCard(
              progress: categories[index],
              userId: userId,
            ),
          );
        },
      ),
    );
  }
}
