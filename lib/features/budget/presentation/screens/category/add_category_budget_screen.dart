import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'set_category_budget_amount_screen.dart';

class AddCategoryBudgetScreen extends StatefulWidget {
  final int userId;

  const AddCategoryBudgetScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddCategoryBudgetScreen> createState() {
    return _AddCategoryBudgetScreenState();
  }
}

class _AddCategoryBudgetScreenState extends State<AddCategoryBudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BudgetCategoryFormViewModel>().resetForm();
        context.read<CategoryViewModel>().loadCategories(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FB);
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    final budgetCategoryVM = context.watch<BudgetCategoryViewModel>();
    final rootCategoryState = context.watch<CategoryViewModel>().state;

    final activeBudgetCategoryIds = budgetCategoryVM.progressList.map((p) {
      return p.budgetCategory.categoryId;
    }).toSet();

    final allExpenseCategories = rootCategoryState.categories.where((cat) {
      return cat.type == 'expense';
    }).toList();

    final availableCategories = allExpenseCategories.where((cat) {
      return !activeBudgetCategoryIds.contains(cat.id);
    }).toList();

    final disabledCategories = allExpenseCategories.where((cat) {
      return activeBudgetCategoryIds.contains(cat.id);
    }).toList();

    final sortedCategories = [...availableCategories, ...disabledCategories];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
        title: AppLocalizations.translate('Select Category'),
        showBack: true,
        onBack: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.translate(
                        'Select a category to establish your expense budget plan.'),
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // DANH SÁCH WHITE CARD PHẲNG CHUẨN FINTECH HỆ GOAL
            Expanded(
              child: rootCategoryState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.sm),
                      itemCount: sortedCategories.length,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (_, __) {
                        return const SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        final category = sortedCategories[index];
                        final isAlreadyCreated =
                            activeBudgetCategoryIds.contains(category.id);
                        final categoryColor = Color(category.colorValue);

                        return Opacity(
                          opacity: isAlreadyCreated ? 0.55 : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isDark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.015),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabled: !isAlreadyCreated,
                              onTap: () {
                                // FIX ĐỘNG: Đọc instance bằng context.read để giữ đúng vùng nhớ data
                                final formVM =
                                    context.read<BudgetCategoryFormViewModel>();
                                formVM.setCategory(category);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return ChangeNotifierProvider.value(
                                        value: formVM,
                                        child: SetCategoryBudgetAmountScreen(
                                            userId: widget.userId),
                                      );
                                    },
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: categoryColor.withValues(
                                  alpha: isAlreadyCreated ? 0.05 : 0.12,
                                ),
                                child: Icon(
                                  IconData(
                                    category.iconCodePoint,
                                    fontFamily: category.iconFontFamily ??
                                        'MaterialIcons',
                                  ),
                                  color: isAlreadyCreated
                                      ? Colors.grey
                                      : categoryColor,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: isAlreadyCreated
                                      ? Colors.grey
                                      : primaryTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: isAlreadyCreated
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1A1D24)
                                            : const Color(0xFFF4F5F7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        AppLocalizations.translate(
                                            'Has Budget'),
                                        style: AppTextStyles.overline.copyWith(
                                          color: isDark
                                              ? Colors.grey[500]
                                              : Colors.grey[600],
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12,
                                      color: secondaryTextColor,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
