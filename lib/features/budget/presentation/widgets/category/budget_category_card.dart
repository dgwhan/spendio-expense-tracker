import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/dialogs/app_dialogs.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/widgets/common/app_more_menu_button.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
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
    final confirmed = await AppDialogs.showDelete(
      context: context,
      title: 'Delete Limit',
      content:
          'Are you sure you want to delete the budget limit for ${progress.budgetCategory.name}?',
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
    final coreCategoryEntity = CategoryEntity(
        id: associatedCategory.id,
        userId: userId,
        name: associatedCategory.name,
        type: associatedCategory.type,
        groupName: associatedCategory.groupName,
        iconCodePoint: associatedCategory.iconCodePoint,
        iconFontFamily: associatedCategory.iconFontFamily,
        colorValue: associatedCategory.colorValue);

    final moreMenu = AppMoreMenuButton(
      iconColor: secondaryTextColor,
      actions: [
        AppMenuAction(
            label: 'Edit Limit',
            value: 'edit',
            icon: Icons.edit_outlined,
            onTap: () => _navigateToEdit(context, coreCategoryEntity)),
        AppMenuAction(
            label: 'Delete',
            value: 'delete',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: () => _handleDelete(context)),
      ],
    );

    if (cardType == BudgetCardType.horizontal) {
      return Container(
        decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: InkWell(
          onTap: () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                          IconData(associatedCategory.iconCodePoint,
                              fontFamily: associatedCategory.iconFontFamily ??
                                  'MaterialIcons'),
                          size: 20,
                          color: categoryColor),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName,
                              style: AppTextStyles.bodyNormal.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor),
                              overflow: TextOverflow.ellipsis),
                          Text(
                              '${formatCurrency(progress.spent, currencyCode: category.currencyCode, locale: context.currencyContext.locale)} of ${formatCurrency(category.amount, currencyCode: category.currencyCode, locale: context.currencyContext.locale)} spent',
                              style: AppTextStyles.caption
                                  .copyWith(color: secondaryTextColor)),
                        ],
                      ),
                    ),
                    Text('$displayPercent%',
                        style: AppTextStyles.bodyNormal.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor)),
                    moreMenu,
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                    value: percentage,
                    minHeight: 5,
                    backgroundColor: isDark
                        ? AppColors.surfaceSecondaryDark
                        : AppColors.surfaceSecondaryLight,
                    valueColor: AlwaysStoppedAnimation<Color>(categoryColor)),
              ],
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
          ]),
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                      IconData(associatedCategory.iconCodePoint,
                          fontFamily: associatedCategory.iconFontFamily ??
                              'MaterialIcons'),
                      size: 16,
                      color: categoryColor),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(displayName,
                          style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor),
                          overflow: TextOverflow.ellipsis)),
                  moreMenu,
                ],
              ),
              const SizedBox(height: 8),
              Text(formatCurrency(progress.spent, currencyCode: category.currencyCode, locale: context.currencyContext.locale),
                  style: AppTextStyles.bodyNormal.copyWith(
                      fontWeight: FontWeight.w800, color: primaryTextColor)),
              Text('of ${formatCurrency(category.amount, currencyCode: category.currencyCode, locale: context.currencyContext.locale)}',
                  style: AppTextStyles.caption
                      .copyWith(fontSize: 10, color: mutedTextColor)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                  value: percentage,
                  minHeight: 4,
                  backgroundColor: isDark
                      ? AppColors.surfaceSecondaryDark
                      : AppColors.surfaceSecondaryLight,
                  valueColor: AlwaysStoppedAnimation<Color>(categoryColor)),
              const SizedBox(height: 4),
              Text('$displayPercent% Spent',
                  style: AppTextStyles.caption.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: categoryColor)),
            ],
          ),
        ),
      ),
    );
  }
}
