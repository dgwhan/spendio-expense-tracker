import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/budget/presentation/screens/category/add_category_budget_screen.dart';
import 'package:spend_io_app/features/budget/presentation/screens/category/edit_category_budget_screen.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/screens/monthly/add_budget_screen.dart';
import 'package:spend_io_app/features/budget/presentation/screens/budget_detail_screen.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/section/budget_section.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_entity.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';

class WalletBudgetCategoriesGrid extends StatefulWidget {
  final int userId;

  const WalletBudgetCategoriesGrid({super.key, required this.userId});

  @override
  State<WalletBudgetCategoriesGrid> createState() =>
      _WalletBudgetCategoriesGridState();
}

class _WalletBudgetCategoriesGridState
    extends State<WalletBudgetCategoriesGrid> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BudgetViewModel>().loadBudget(widget.userId);
        context.read<BudgetCategoryViewModel>().loadCategories(widget.userId);
        context.read<BudgetCategoryViewModel>().loadProgress(widget.userId);
      }
    });
  }

  void _refreshBudgetAndWalletData() {
    if (mounted) {
      context.read<BudgetViewModel>().loadBudget(widget.userId);
      context.read<BudgetCategoryViewModel>().loadCategories(widget.userId);
      context.read<BudgetCategoryViewModel>().loadProgress(widget.userId);
      context.read<WalletViewModel>().refreshBudgetProgress();
    }
  }

  void _navigateToCreateBudget() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BudgetFormViewModel>(
          create: (_) => BudgetFormViewModel(),
          child: AddBudgetScreen(userId: widget.userId),
        ),
      ),
    );
    _refreshBudgetAndWalletData();
  }

  // ✅ ĐÃ TỐI ƯU: Truyền thẳng budgetCategory.amount qua Constructor của màn hình Edit
  void _navigateToCategoryBudgetForm({
    BudgetCategoryEntity? budgetCategory,
    CategoryEntity? categoryDetails,
  }) async {
    final bool isEdit = budgetCategory != null && categoryDetails != null;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BudgetCategoryFormViewModel>(
          create: (_) {
            final formVM = BudgetCategoryFormViewModel();
            if (isEdit) {
              formVM.setupEditMode(budgetCategory, categoryDetails);
            } else {
              formVM.resetForm();
            }
            return formVM;
          },
          child: isEdit
              ? EditCategoryBudgetScreen(
                  userId: widget.userId,
                  initialAmount: budgetCategory
                      .amount, // Bắn số tiền gốc sang thẳng màn hình Edit
                )
              : AddCategoryBudgetScreen(userId: widget.userId),
        ),
      ),
    );

    if (result == true) {
      _refreshBudgetAndWalletData();
    }
  }

  void _navigateToDetailBudget(
      double totalSpent, double totalBudget, int daysLeft) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetDetailScreen(
          totalSpent: totalSpent,
          totalBudget: totalBudget,
          daysLeft: daysLeft,
          userId: widget.userId,
        ),
      ),
    );
    _refreshBudgetAndWalletData();
  }

  @override
  Widget build(BuildContext context) {
    final budgetVM = context.watch<BudgetViewModel>();
    final categoryVM = context.watch<BudgetCategoryViewModel>();

    final currentBudgetProgress = budgetVM.currentBudget;
    final totalSpent = currentBudgetProgress?.spent ?? 0.0;
    final totalBudget = currentBudgetProgress?.budget.amount ?? 0.0;

    int daysLeft = 0;
    if (currentBudgetProgress != null) {
      daysLeft = currentBudgetProgress.budget.endDate
          .difference(DateTime.now())
          .inDays;
      if (daysLeft < 0) {
        daysLeft = 0;
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            BudgetSection(
              totalSpent: totalSpent,
              totalBudget: totalBudget,
              daysLeft: daysLeft,
              categories: categoryVM.progressList,
              userId: widget.userId,
              onCreateBudgetTap: _navigateToCreateBudget,
              onGetDetailBudgetTap: () =>
                  _navigateToDetailBudget(totalSpent, totalBudget, daysLeft),
              onCreateCategoryBudgetTap: () {
                _navigateToCategoryBudgetForm();
              },
              onEditCategoryBudgetTap: (budgetCategory, categoryDetails) {
                _navigateToCategoryBudgetForm(
                  budgetCategory: budgetCategory,
                  categoryDetails: categoryDetails,
                );
              },
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}
