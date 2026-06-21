import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/budget/presentation/screens/category/budget_category_detail_screen.dart';
import 'package:spend_io_app/features/budget/presentation/screens/category/edit_category_budget_screen.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/data/models/category_model.dart';

enum BudgetCardType { horizontal, vertical }

class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategoryProgressEntity progress;
  final int userId;
  final BudgetCardType cardType;

  const BudgetCategoryCard({
    super.key,
    required this.progress,
    required this.userId,
    this.cardType = BudgetCardType.vertical,
  });

  void _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Limit'),
        content: Text(
            'Are you sure you want to delete the budget limit for ${progress.budgetCategory.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<BudgetCategoryViewModel>().deleteCategory(
            id: progress.budgetCategory.id,
            userId: userId,
          );
    }
  }

  void _navigateToEdit(BuildContext context, CategoryEntity currentDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BudgetCategoryFormViewModel>(
          create: (_) => BudgetCategoryFormViewModel(),
          child: Builder(
            builder: (routeContext) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                routeContext.read<BudgetCategoryFormViewModel>().setupEditMode(
                      progress.budgetCategory,
                      currentDetails,
                    );
              });
              return EditCategoryBudgetScreen(userId: userId);
            },
          ),
        ),
      ),
    ).then((updated) {
      if (updated == true && context.mounted) {
        context.read<BudgetCategoryViewModel>().loadProgress(userId);
      }
    });
  }

  Widget _buildPopupMenu(
      BuildContext context, Color iconColor, CategoryEntity currentDetails) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: iconColor, size: 18),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onSelected: (value) {
        if (value == 'edit') {
          _navigateToEdit(context, currentDetails);
        } else if (value == 'delete') {
          _handleDelete(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 16),
              SizedBox(width: 8),
              Text('Edit Limit', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.error),
              SizedBox(width: 8),
              Text('Delete',
                  style: TextStyle(color: AppColors.error, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

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

    final CategoryEntity coreCategoryEntity = CategoryEntity(
      id: associatedCategory.id,
      userId: userId,
      name: associatedCategory.name,
      type: associatedCategory.type,
      groupName: associatedCategory.groupName,
      iconCodePoint: associatedCategory.iconCodePoint,
      iconFontFamily: associatedCategory.iconFontFamily,
      colorValue: associatedCategory.colorValue,
    );

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
                      const SizedBox(width: 4),
                      _buildPopupMenu(
                          context, secondaryTextColor, coreCategoryEntity),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        IconData(associatedCategory.iconCodePoint,
                            fontFamily: associatedCategory.iconFontFamily ??
                                'MaterialIcons'),
                        size: 18,
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            height: 1.2),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    _buildPopupMenu(
                        context, secondaryTextColor, coreCategoryEntity),
                  ],
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 4,
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
