import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/input/app_search_bar.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Limit'),
        content: Text(
            'Are you sure you want to delete the budget limit for ${widget.progress.budgetCategory.name}?'),
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
      final success =
          await context.read<BudgetCategoryViewModel>().deleteCategory(
                id: widget.progress.budgetCategory.id,
                userId: widget.userId,
              );

      if (success && context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _navigateToEdit(
      BuildContext context, BudgetCategoryProgressEntity currentProgress) {
    final rootCategoryList = context.read<CategoryViewModel>().state.categories;

    final hasMatch = rootCategoryList.any(
        (element) => element.id == currentProgress.budgetCategory.categoryId);

    final CategoryEntity currentDetails = hasMatch
        ? rootCategoryList.firstWhere((element) =>
            element.id == currentProgress.budgetCategory.categoryId)
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BudgetCategoryFormViewModel>(
          create: (_) => BudgetCategoryFormViewModel()
            ..setupEditMode(
              currentProgress.budgetCategory,
              currentDetails,
            ),
          child: EditCategoryBudgetScreen(userId: widget.userId),
        ),
      ),
    ).then((updated) {
      if (updated == true && context.mounted) {
        context.read<BudgetCategoryViewModel>().loadProgress(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final budgetVM = context.watch<BudgetCategoryViewModel>();

    final currentProgress = budgetVM.progressList.firstWhere(
      (element) =>
          element.budgetCategory.id == widget.progress.budgetCategory.id,
      orElse: () => widget.progress,
    );

    final category = currentProgress.budgetCategory;
    final rootCategories = context.watch<CategoryViewModel>().state.categories;
    final allTransactions =
        context.watch<TransactionViewModel>().state.transactions;

    final filteredTransactions = allTransactions.where((tx) {
      final isSameCategory = tx.categoryId == category.categoryId;
      final isWithinPeriod = tx.transactionDate.isAfter(
              category.startDate.subtract(const Duration(milliseconds: 1))) &&
          tx.transactionDate
              .isBefore(category.endDate.add(const Duration(milliseconds: 1)));

      final matchesSearch = _searchQuery.isEmpty ||
          (tx.note != null &&
              tx.note!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          tx.amount.toString().contains(_searchQuery);

      return isSameCategory && isWithinPeriod && matchesSearch;
    }).toList();

    final systemBottomPadding = MediaQuery.of(context).padding.bottom;

    final isOverBudget = currentProgress.remaining < 0;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSizes.sm),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: primaryTextColor, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('Limit Detail'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.md),
                    Stack(
                      children: [
                        SpentStatusCard(
                          progress: currentProgress,
                          isDark: isDark,
                        ),
                        Positioned(
                          top: AppSizes.md,
                          right: AppSizes.md,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isOverBudget
                                      ? AppColors.error.withValues(alpha: 0.1)
                                      : AppColors.primary
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isOverBudget
                                          ? Icons.error_outline_rounded
                                          : Icons.check_circle_outline_rounded,
                                      size: 13,
                                      color: isOverBudget
                                          ? AppColors.error
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isOverBudget ? 'OVER' : 'SAFE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isOverBudget
                                            ? AppColors.error
                                            : AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSizes.xs),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_horiz_rounded,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                    size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _navigateToEdit(context, currentProgress);
                                  } else if (value == 'delete') {
                                    _handleDelete(context);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit Limit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded,
                                            size: 18, color: AppColors.error),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style: TextStyle(
                                                color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xl),
                    AppSearchBar(
                      controller: _searchController,
                      hintText: 'Search transactions...',
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onClear: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Text(
                      'Category History',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor),
                    ),
                  ],
                ),
              ),
            ),
            if (filteredTransactions.isEmpty)
              _buildEmptyState()
            else
              ..._buildTransactionSlivers(
                  filteredTransactions, rootCategories, context),
            SliverPadding(
              padding:
                  EdgeInsets.only(bottom: systemBottomPadding + AppSizes.xl),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTransactionSlivers(List<TransactionEntity> transactions,
      List<CategoryEntity> categories, BuildContext context) {
    final Map<String, List<TransactionEntity>> grouped = {};
    for (final tx in transactions) {
      final key = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final List<Widget> slivers = [];

    for (final key in sortedKeys) {
      final txList = grouped[key]!
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      slivers.add(
        SliverToBoxAdapter(
          child: DateGroupHeader(dateKey: key),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final currentTx = txList[index];

              return AccountTransactionItem(
                tx: currentTx,
                categories: categories,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailScreen(
                        transaction: currentTx,
                        categories: categories,
                        transactionVM: context.read<TransactionViewModel>(),
                      ),
                    ),
                  );
                },
              );
            },
            childCount: txList.length,
          ),
        ),
      );
    }

    return slivers;
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 44,
                color: Colors.grey.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                _searchQuery.isEmpty
                    ? 'No transactions in this period'
                    : 'No matching results found',
                style: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
