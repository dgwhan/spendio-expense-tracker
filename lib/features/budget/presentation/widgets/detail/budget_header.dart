import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/input/app_search_bar.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/delete_budget_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/category/budget_category_card.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/detail/progress_indicator_card.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';

class BudgetDetailScreen extends StatefulWidget {
  final double totalSpent;
  final double totalBudget;
  final int daysLeft;
  final int userId;

  const BudgetDetailScreen({
    super.key,
    required this.totalSpent,
    required this.totalBudget,
    required this.daysLeft,
    required this.userId,
  });

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BudgetCategoryViewModel>().loadProgress(widget.userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final systemBottomPadding = MediaQuery.of(context).padding.bottom;

    final budgetCategoryVM = context.watch<BudgetCategoryViewModel>();
    final allCategoryProgress = budgetCategoryVM.progressList;

    final filteredCategories = allCategoryProgress.where((progress) {
      final categoryName = progress.budgetCategory.name.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return categoryName.contains(query);
    }).toList();

    final remaining = widget.totalBudget - widget.totalSpent;
    final percentage = widget.totalBudget > 0
        ? (widget.totalSpent / widget.totalBudget).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = remaining < 0;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSizes.md),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: primaryTextColor, size: 18),
            onPressed: () => Navigator.pop(context),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Text(
          'Budget Overview',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: primaryTextColor),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: budgetCategoryVM.isLoading && allCategoryProgress.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProgressIndicatorCard(
                            totalSpent: widget.totalSpent,
                            totalBudget: widget.totalBudget,
                            percentage: percentage,
                            isOverBudget: isOverBudget,
                            daysLeft: widget.daysLeft,
                            userId: widget.userId,
                            budgetVM: context.read<BudgetViewModel>(),
                            walletVM: context.read<WalletViewModel>(),
                            updateBudgetUseCase:
                                context.read<UpdateBudgetUseCase>(),
                            deleteBudgetUseCase:
                                context.read<DeleteBudgetUseCase>(),
                          ),
                          const SizedBox(height: AppSizes.xl),
                          AppSearchBar(
                            controller: _searchController,
                            hintText: 'Search category budgets...',
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            onClear: () => setState(() => _searchQuery = ''),
                          ),
                          const SizedBox(height: AppSizes.xl),
                          Text(
                            'Category Budgets',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor),
                          ),
                          const SizedBox(height: AppSizes.md),
                        ],
                      ),
                    ),
                  ),
                  if (filteredCategories.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final currentProgress = filteredCategories[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSizes.md),
                              child: BudgetCategoryCard(
                                progress: currentProgress,
                                userId: widget.userId,
                                cardType: BudgetCardType.horizontal,
                              ),
                            );
                          },
                          childCount: filteredCategories.length,
                        ),
                      ),
                    ),
                  SliverPadding(
                      padding: EdgeInsets.only(
                          bottom: systemBottomPadding + AppSizes.xl)),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl * 2),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off_outlined,
                size: 48, color: Colors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: AppSizes.sm),
            Text(
              _searchQuery.isEmpty
                  ? 'No category budgets found'
                  : 'No matching budgets found',
              style: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.6), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
