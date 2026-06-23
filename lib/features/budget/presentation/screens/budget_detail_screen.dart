import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/common/app_empty_state.dart';
import 'package:spend_io_app/core/widgets/input/app_search_bar.dart';
import 'package:spend_io_app/features/account/presentation/widgets/filter/account_list_subheader.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/delete_budget_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/presentation/screens/monthly/add_budget_screen.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_form_viewmodel.dart';
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
  AccountSortOption _currentSort = AccountSortOption.newest;

  @override
  void initState() {
    super.initState();
    // ✅ FIX TRIỆT ĐỂ: Hoãn tiến trình gọi dữ liệu bất đồng bộ cho đến khi Widget dựng xong hoàn toàn khung xương UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleRefreshData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefreshData() async {
    if (!mounted) return;
    await context.read<BudgetCategoryViewModel>().loadProgress(widget.userId);
    if (mounted) {
      await context.read<BudgetViewModel>().loadBudget(widget.userId);
    }
  }

  void _navigateToCreateBudget() async {
    final walletVM = context.read<WalletViewModel>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => BudgetFormViewModel(),
          child: AddBudgetScreen(userId: widget.userId),
        ),
      ),
    );

    if (mounted) {
      await _handleRefreshData();
      await walletVM.refreshBudgetProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final budgetVM = context.watch<BudgetViewModel>();
    final budgetCategoryVM = context.watch<BudgetCategoryViewModel>();

    final currentBudgetEntity = budgetVM.currentBudget?.budget;
    final hasBudget =
        currentBudgetEntity != null && currentBudgetEntity.amount > 0;

    final displayBudget =
        hasBudget ? currentBudgetEntity.amount : widget.totalBudget;
    final displaySpent =
        hasBudget ? budgetVM.currentBudget!.spent : widget.totalSpent;

    final filteredCategories = budgetCategoryVM.progressList
        .where((p) => p.budgetCategory.name
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    switch (_currentSort) {
      case AccountSortOption.nameAZ:
        filteredCategories.sort((a, b) => a.budgetCategory.name
            .toLowerCase()
            .compareTo(b.budgetCategory.name.toLowerCase()));
        break;
      case AccountSortOption.newest:
        filteredCategories
            .sort((a, b) => b.budgetCategory.id.compareTo(a.budgetCategory.id));
        break;
      case AccountSortOption.oldest:
        filteredCategories
            .sort((a, b) => a.budgetCategory.id.compareTo(b.budgetCategory.id));
        break;
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppHeader(
          title: 'Budget Overview',
          showBack: true,
          onBack: () => Navigator.pop(context)),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _handleRefreshData,
          child: budgetCategoryVM.isLoading &&
                  budgetCategoryVM.progressList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasBudget)
                              ProgressIndicatorCard(
                                totalSpent: displaySpent,
                                totalBudget: displayBudget,
                                percentage: displayBudget > 0
                                    ? (displaySpent / displayBudget)
                                        .clamp(0.0, 1.0)
                                    : 0.0,
                                isOverBudget:
                                    (displayBudget - displaySpent) < 0,
                                daysLeft: widget.daysLeft,
                                userId: widget.userId,
                                budgetVM: budgetVM,
                                walletVM: context.read<WalletViewModel>(),
                                updateBudgetUseCase:
                                    context.read<UpdateBudgetUseCase>(),
                                deleteBudgetUseCase:
                                    context.read<DeleteBudgetUseCase>(),
                              )
                            else
                              _buildEmptyBudgetCard(isDark, primaryTextColor),
                            const SizedBox(height: AppSizes.xl),
                            Text('Category Budgets',
                                style: AppTextStyles.sectionTitle.copyWith(
                                    color: primaryTextColor, fontSize: 18)),
                            const SizedBox(height: AppSizes.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: AppSearchBar(
                                    controller: _searchController,
                                    hintText: 'Search...',
                                    onChanged: (v) =>
                                        setState(() => _searchQuery = v),
                                    onClear: () =>
                                        setState(() => _searchQuery = ''),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.sm),
                                AccountListSubheader(
                                  currentSort: _currentSort,
                                  onSortSelected: (option) =>
                                      setState(() => _currentSort = option),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.md),
                          ],
                        ),
                      ),
                    ),
                    if (filteredCategories.isEmpty)
                      SliverToBoxAdapter(
                        child: AppEmptyState(
                          title: 'No category budgets found',
                          subtitle: 'No matching budgets found',
                          icon: Icons.folder_off_outlined,
                        ),
                      )
                    else
                      SliverPadding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppSizes.md),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSizes.md),
                              child: BudgetCategoryCard(
                                progress: filteredCategories[index],
                                userId: widget.userId,
                                cardType: BudgetCardType.horizontal,
                              ),
                            ),
                            childCount: filteredCategories.length,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyBudgetCard(bool isDark, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
      ),
      child: Column(
        children: [
          Text('No Monthly Budget Set',
              style: AppTextStyles.bodyNormal
                  .copyWith(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: AppSizes.md),
          ElevatedButton(
              onPressed: _navigateToCreateBudget,
              child: const Text('Add Budget Month')),
        ],
      ),
    );
  }
}
