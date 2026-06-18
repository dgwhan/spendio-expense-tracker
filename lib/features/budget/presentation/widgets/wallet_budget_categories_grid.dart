import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/common/app_empty_state.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart'; // ĐỔI THÀNH: Progress Entity
import 'package:spend_io_app/features/budget/presentation/widgets/budget_category_card.dart';

class WalletBudgetCategoriesGrid extends StatelessWidget {
  final List<BudgetCategoryProgressEntity>
      categories; // ĐỔI KIỂU: Chứa thông tin tiến độ chi tiêu
  final ValueChanged<BudgetCategoryProgressEntity>?
      onTapCategory; // ĐỔI KIỂU tương ứng cho callback

  const WalletBudgetCategoriesGrid({
    super.key,
    required this.categories,
    this.onTapCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (categories.isEmpty) {
      return const AppEmptyState(
        title: 'No Budget Categories',
        subtitle: 'Create categories to track spending behavior',
        icon: Icons.pie_chart_outline_rounded,
        isBordered: true,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.md,
        mainAxisSpacing: AppSizes.md,
        childAspectRatio: 0.95,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final entity = categories[index];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 250 + (index * 40)),
          tween: Tween(begin: 0.9, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () => onTapCategory?.call(entity),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1A1D2E),
                          const Color(0xFF0F111A),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFF7F9FF),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.25 : 0.06,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ),
              child: BudgetCategoryCard(
                category:
                    entity, // Đã khớp kiểu dữ liệu mượt mà, sạch lỗi compile!
                onTap: () => onTapCategory?.call(entity),
              ),
            ),
          ),
        );
      },
    );
  }
}
