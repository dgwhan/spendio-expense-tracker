import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/delete_budget_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/presentation/screens/monthly/edit_budget_screen.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';

class ProgressIndicatorCard extends StatelessWidget {
  final double totalSpent;
  final double totalBudget;
  final double percentage;
  final bool isOverBudget;
  final int daysLeft;
  final int userId;

  final BudgetViewModel budgetVM;
  final WalletViewModel walletVM;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;

  const ProgressIndicatorCard({
    super.key,
    required this.totalSpent,
    required this.totalBudget,
    required this.percentage,
    required this.isOverBudget,
    required this.daysLeft,
    required this.userId,
    required this.budgetVM,
    required this.walletVM,
    required this.updateBudgetUseCase,
    required this.deleteBudgetUseCase,
  });

  void _handleDeleteBudget(BuildContext context) async {
    final currentBudgetEntity = budgetVM.currentBudget?.budget;
    if (currentBudgetEntity == null) return;

    final budgetId = currentBudgetEntity.id;
    final shortIdDisplay =
        '[#${budgetId.length >= 5 ? budgetId.substring(0, 5) : budgetId.padRight(5, '0')}]';

    debugPrint(
        '[UX ACTION]: Clicked Delete Budget for id: $shortIdDisplay. Showing confirmation alert dialog...');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Monthly Budget'),
        content: const Text(
            'Are you sure you want to delete this month\'s total budget? This will remove your main balance constraint.'),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint(
                  '[UX ACTION]: Cancelled budget deletion from dialog for id: $shortIdDisplay.');
              Navigator.pop(ctx, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              debugPrint(
                  '[UX ACTION]: Confirmed budget deletion from dialog for id: $shortIdDisplay.');
              Navigator.pop(ctx, true);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      debugPrint(
          '[PIPELINE EXECUTE]: Triggering SQLite delete for budget id: $shortIdDisplay');
      await budgetVM.deleteBudget(
        budgetId: currentBudgetEntity.id,
        userId: userId,
      );
      await walletVM.refreshBudgetProgress();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _navigateToEditBudget(BuildContext context) {
    final budgetState = budgetVM.currentBudget;

    if (budgetState == null) {
      debugPrint('[ERR]: Cannot navigate to Edit, currentBudget is null!');
      return;
    }

    final budgetId = budgetState.budget.id;
    final shortIdDisplay =
        '[#${budgetId.length >= 5 ? budgetId.substring(0, 5) : budgetId.padRight(5, '0')}]';

    debugPrint(
        '[NAVIGATION]: Routing to EditBudgetScreen for id: $shortIdDisplay');
    debugPrint(
        '[DATA LOG]: Budget Entity Full ID: $budgetId | Existing Amount: ${budgetState.budget.amount}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  BudgetFormViewModel()..setupEditMode(budgetState.budget),
            ),
            ChangeNotifierProvider.value(value: budgetVM),
            Provider.value(value: updateBudgetUseCase),
            Provider.value(value: deleteBudgetUseCase),
            ChangeNotifierProvider.value(value: walletVM),
          ],
          child: EditBudgetScreen(
            userId: userId,
            existingBudget: budgetState.budget,
          ),
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

    final displayPercent = (percentage * 100).toStringAsFixed(0);
    final DateTime now = DateTime.now();
    final String currentMonthStr =
        '${DateFormat.MMM().format(now)} ${now.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowNatural1,
            blurRadius: 16,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentMonthStr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOverBudget
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
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
                        color: secondaryTextColor, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onOpened: () {
                      final currentBudgetEntity =
                          budgetVM.currentBudget?.budget;
                      final shortIdDisplay = currentBudgetEntity != null
                          ? '[#${currentBudgetEntity.id.length >= 5 ? currentBudgetEntity.id.substring(0, 5) : currentBudgetEntity.id.padRight(5, '0')}]'
                          : '[#unknown]';
                      debugPrint(
                          '[UX EVENT]: Popup context menu expanded via horiz button for id: $shortIdDisplay.');
                    },
                    onSelected: (value) {
                      debugPrint(
                          '[UX EVENT]: Context item selected string action token: "$value"');
                      if (value == 'edit') {
                        _navigateToEditBudget(context);
                      } else if (value == 'delete') {
                        _handleDeleteBudget(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Budget'),
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
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 10,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? AppColors.error : const Color(0xFF0052CC),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$displayPercent%',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor,
                    ),
                  ),
                  Text(
                    'SPENT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'SPENT THIS MONTH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatCurrency(totalSpent),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Budget',
                    style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(totalBudget),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$daysLeft days left',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0052CC),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
