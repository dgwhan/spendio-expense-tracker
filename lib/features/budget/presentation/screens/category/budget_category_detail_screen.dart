import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/dialogs/app_dialogs.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/common/app_more_menu_button.dart';
import 'package:spend_io_app/core/widgets/input/app_search_bar.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/filter/account_list_subheader.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/screens/category/edit_category_budget_screen.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/detail/date_group_header.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/detail/spent_status_card.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/transaction_detail_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/components/account_transaction_item.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/components/account_transaction_sort_button.dart';

class BudgetCategoryDetailScreen extends StatefulWidget {
  final BudgetCategoryProgressEntity progress;
  final int userId;

  const BudgetCategoryDetailScreen({
    super.key,
    required this.progress,
    required this.userId,
  });

  @override
  State<BudgetCategoryDetailScreen> createState() =>
      _BudgetCategoryDetailScreenState();
}

class _BudgetCategoryDetailScreenState
    extends State<BudgetCategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  AccountSortOption _transactionSort = AccountSortOption.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    final navigator = Navigator.of(context);
    final confirmed = await AppDialogs.showDelete(
      context: context,
      title: 'Delete Limit',
      content:
          'Are you sure you want to delete the budget limit for ${widget.progress.budgetCategory.name}?',
    );

    if (confirmed == true && mounted) {
      final success =
          await context.read<BudgetCategoryViewModel>().deleteCategory(
                id: widget.progress.budgetCategory.id,
                userId: widget.userId,
              );
      if (success && mounted) Future.microtask(() => navigator.pop());
    }
  }

  void _navigateToEdit(BudgetCategoryProgressEntity currentProgress) async {
    final rootCategoryList = context.read<CategoryViewModel>().state.categories;
    final budgetVM = context.read<BudgetCategoryViewModel>();

    final hasMatch = rootCategoryList
        .any((e) => e.id == currentProgress.budgetCategory.categoryId);
    final CategoryEntity currentDetails = hasMatch
        ? rootCategoryList.firstWhere(
            (e) => e.id == currentProgress.budgetCategory.categoryId)
        : CategoryEntity(
            id: currentProgress.budgetCategory.categoryId,
            userId: widget.userId,
            name: currentProgress.budgetCategory.name,
            type: 'expense',
            groupName: '',
            iconCodePoint: Icons.category_rounded.codePoint,
            iconFontFamily: 'MaterialIcons',
            colorValue: AppColors.primary.hashCode,
          );

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BudgetCategoryFormViewModel>(
          create: (_) => BudgetCategoryFormViewModel()
            ..setupEditMode(currentProgress.budgetCategory, currentDetails),
          child: EditCategoryBudgetScreen(userId: widget.userId),
        ),
      ),
    );

    if (updated == true && mounted) budgetVM.loadProgress(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final budgetVM = context.watch<BudgetCategoryViewModel>();
    final currentProgress = budgetVM.progressList.firstWhere(
      (e) => e.budgetCategory.id == widget.progress.budgetCategory.id,
      orElse: () => widget.progress,
    );

    final allTransactions =
        context.watch<TransactionViewModel>().state.transactions;

    final filteredTransactions = allTransactions.where((tx) {
      final isSameCategory =
          tx.categoryId == currentProgress.budgetCategory.categoryId;

      final isWithinPeriod = tx.transactionDate.isAfter(currentProgress
              .budgetCategory.startDate
              .subtract(const Duration(milliseconds: 1))) &&
          tx.transactionDate.isBefore(currentProgress.budgetCategory.endDate
              .add(const Duration(milliseconds: 1)));

      final matchesSearch = _searchQuery.isEmpty ||
          (tx.note != null &&
              tx.note!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return isSameCategory && isWithinPeriod && matchesSearch;
    }).toList();

    // Áp dụng Sort dựa trên state mới
    filteredTransactions.sort((a, b) =>
        _transactionSort == AccountSortOption.newest
            ? b.transactionDate.compareTo(a.transactionDate)
            : a.transactionDate.compareTo(b.transactionDate));

    final isOverBudget = currentProgress.remaining < 0;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppHeader(
        title: currentProgress.budgetCategory.name,
        showBack: true,
        onBack: () => Navigator.pop(context),
        actions: [
          AppMoreMenuButton(
            iconColor: primaryTextColor,
            actions: [
              AppMenuAction(
                  label: 'Edit Limit',
                  value: 'edit',
                  icon: Icons.edit_outlined,
                  onTap: () => _navigateToEdit(currentProgress)),
              AppMenuAction(
                  label: 'Delete',
                  value: 'delete',
                  icon: Icons.delete_outline_rounded,
                  isDestructive: true,
                  onTap: _handleDelete),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SpentStatusCard(
                            progress: currentProgress, isDark: isDark),
                        Positioned(
                          top: AppSizes.md,
                          right: AppSizes.md,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: (isOverBudget
                                        ? AppColors.error
                                        : AppColors.primary)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(children: [
                              Icon(
                                  isOverBudget
                                      ? Icons.error_outline_rounded
                                      : Icons.check_circle_outline_rounded,
                                  size: 13,
                                  color: isOverBudget
                                      ? AppColors.error
                                      : AppColors.primary),
                              const SizedBox(width: 4),
                              Text(isOverBudget ? 'OVER' : 'SAFE',
                                  style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isOverBudget
                                          ? AppColors.error
                                          : AppColors.primary)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Category History',
                        style: AppTextStyles.sectionTitle
                            .copyWith(color: primaryTextColor),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppSearchBar(
                            controller: _searchController,
                            hintText: 'Search...',
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        AccountTransactionSortButton(
                          currentSort: _transactionSort,
                          onSortSelected: (val) =>
                              setState(() => _transactionSort = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ..._buildTransactionSlivers(filteredTransactions, context),
            SliverPadding(
                padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(context).padding.bottom + AppSizes.xl)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTransactionSlivers(
      List<TransactionEntity> txs, BuildContext context) {
    final grouped = <String, List<TransactionEntity>>{};
    for (var tx in txs) {
      final key = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    final keys = grouped.keys.toList()
      ..sort((a, b) => _transactionSort == AccountSortOption.newest
          ? b.compareTo(a)
          : a.compareTo(b));

    return keys
        .map(
          (key) => SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(child: DateGroupHeader(dateKey: key)),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (_, i) => AccountTransactionItem(
                            tx: grouped[key]![i],
                            categories: context
                                .watch<CategoryViewModel>()
                                .state
                                .categories,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailScreen(
                                  transaction: grouped[key]![i],
                                  categories: context
                                      .read<CategoryViewModel>()
                                      .state
                                      .categories,
                                  accounts:
                                      context.read<AccountViewModel>().accounts,
                                  transactionVM:
                                      context.read<TransactionViewModel>(),
                                ),
                              ),
                            ),
                          ),
                      childCount: grouped[key]!.length)),
            ],
          ),
        )
        .toList();
  }
}
