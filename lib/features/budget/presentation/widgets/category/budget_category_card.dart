import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/budget/presentation/screens/category/budget_category_detail_screen.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/category/data/models/category_model.dart';

enum BudgetCardType { horizontal, vertical }

class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategoryProgressEntity progress;
  final int userId;
  final BudgetCardType
      cardType; // Kiểu layout: Ngang (Horizontal) hoặc Dọc vuông (Vertical)

  const BudgetCategoryCard({
    super.key,
    required this.progress,
    required this.userId,
    this.cardType =
        BudgetCardType.vertical, // Mặc định là dọc vuông giống ảnh cũ
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final category = progress.budgetCategory;
    final percentage = (progress.percentage / 100.0).clamp(0.0, 1.0);
    final displayName =
        category.name.isNotEmpty ? category.name : category.categoryId;

    final rootCategories = context.watch<CategoryViewModel>().state.categories;
    final fallbackCategory = CategoryModel(
      id: category.categoryId,
      userId: userId,
      name: displayName,
      type: 'expense',
      groupName: 'Other',
      iconCodePoint: Icons.category_rounded.codePoint,
      iconFontFamily: 'MaterialIcons',
      colorValue: AppColors.primary.hashCode,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    final hasCategoryMatch =
        rootCategories.any((e) => e.id == category.categoryId);
    final associatedCategory = hasCategoryMatch
        ? rootCategories.firstWhere((e) => e.id == category.categoryId)
        : fallbackCategory;

    final categoryColor = Color(associatedCategory.colorValue);
    final displayPercent = progress.percentage.toStringAsFixed(0);

    // ==========================================
    // 🛠️ LAYOUT 1: HÀNG NGANG (HORIZONTAL CARD)
    // ==========================================
    if (cardType == BudgetCardType.horizontal) {
      return Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowNatural1,
                blurRadius: 12,
                offset: Offset(0, 4))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToDetail(context),
            borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconData(associatedCategory.iconCodePoint,
                              fontFamily: associatedCategory.iconFontFamily ??
                                  'MaterialIcons'),
                          size: 24,
                          color: categoryColor,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${formatCurrency(progress.spent)} of ${formatCurrency(category.amount)} spent',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        '$displayPercent%',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? AppColors.surfaceSecondaryDark
                          : AppColors.surfaceSecondaryLight,
                      valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ==========================================
    // 🛠️ LAYOUT 2: Ô VUÔNG DỌC (VERTICAL CARD) - ĐÃ FIX CHỐNG TRÀN FLEX
    // ==========================================
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowNatural1,
              blurRadius: 12,
              offset: Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical:
                    8), // Giảm nhẹ padding dọc xuống 8px để tăng không gian thở
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Icon Box
                Container(
                  padding: const EdgeInsets.all(
                      4), // Thu nhỏ nhẹ padding icon chống kích thước lớn
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    IconData(associatedCategory.iconCodePoint,
                        fontFamily: associatedCategory.iconFontFamily ??
                            'MaterialIcons'),
                    size:
                        18, // Hạ nhẹ từ 20 xuống 18 để fit khít khung h=76 cực đoan
                    color: categoryColor,
                  ),
                ),

                // 2. Title Name
                Text(
                  displayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),

                // 3. Currency Row
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          formatCurrency(progress.spent),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor),
                        ),
                        Text(
                          ' / ${formatCurrency(category.amount)}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: mutedTextColor),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Progress Bar
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight:
                            4, // Hạ xuống 4px để tiết kiệm diện tích dọc tối đa
                        backgroundColor: isDark
                            ? AppColors.surfaceSecondaryDark
                            : AppColors.surfaceSecondaryLight,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(categoryColor),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$displayPercent% Spent',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: categoryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetCategoryDetailScreen(
          progress: progress,
          userId: userId,
        ),
      ),
    );
  }
}
