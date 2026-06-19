import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
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
  State<AddCategoryBudgetScreen> createState() =>
      _AddCategoryBudgetScreenState();
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
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final formVM = context.watch<BudgetCategoryFormViewModel>();
    final budgetCategoryVM = context.watch<BudgetCategoryViewModel>();
    final rootCategoryState = context.watch<CategoryViewModel>().state;

    final activeBudgetCategoryIds = budgetCategoryVM.progressList
        .map((p) => p.budgetCategory.categoryId)
        .toSet();
    final allExpenseCategories = rootCategoryState.categories
        .where((cat) => cat.type == 'expense')
        .toList();

    final availableCategories = allExpenseCategories
        .where((cat) => !activeBudgetCategoryIds.contains(cat.id))
        .toList();
    final disabledCategories = allExpenseCategories
        .where((cat) => activeBudgetCategoryIds.contains(cat.id))
        .toList();
    final sortedCategories = [...availableCategories, ...disabledCategories];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: primaryTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Category',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primaryTextColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg, vertical: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Category',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Select a category to establish your target limit.',
                    style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: rootCategoryState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.lg, vertical: AppSizes.sm),
                      itemCount: sortedCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final category = sortedCategories[index];
                        final isAlreadyCreated =
                            activeBudgetCategoryIds.contains(category.id);
                        final isSelected =
                            formVM.selectedCategory?.id == category.id;
                        final categoryColor = Color(category.colorValue);

                        return Opacity(
                          opacity: isAlreadyCreated ? 0.45 : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? categoryColor.withValues(alpha: 0.08)
                                  : (isAlreadyCreated
                                      ? cardColor.withValues(alpha: 0.6)
                                      : cardColor),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected
                                    ? categoryColor
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md)),
                              enabled: !isAlreadyCreated,
                              onTap: () {
                                // 1. Lưu danh mục đã chọn vào ViewModel
                                formVM.setCategory(category);

                                // 2. Ép sử dụng .value để mang Instance data sang màn hình sau không bị null
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: formVM,
                                      child: SetCategoryBudgetAmountScreen(
                                          userId: widget.userId),
                                    ),
                                  ),
                                );
                              },
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(
                                      alpha: isAlreadyCreated ? 0.04 : 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  IconData(category.iconCodePoint,
                                      fontFamily: category.iconFontFamily ??
                                          'MaterialIcons'),
                                  color: isAlreadyCreated
                                      ? Colors.grey
                                      : categoryColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isAlreadyCreated
                                      ? Colors.grey
                                      : primaryTextColor,
                                ),
                              ),
                              trailing: isAlreadyCreated
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Has Budget',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  : Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14, color: secondaryTextColor),
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
