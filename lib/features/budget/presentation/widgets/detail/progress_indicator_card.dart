import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/dialogs/app_dialogs.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/widgets/common/app_more_menu_button.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/delete_budget_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/presentation/screens/monthly/edit_budget_screen.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';

// Đảm bảo không xóa logic DateFormatter của bạn
class DateFormatter {
  static String toMonthYearString(DateTime date) => monthYear(date);
}

String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);
String shortDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
String relativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final targetDate = DateTime(date.year, date.month, date.day);
  if (targetDate == today) return 'Today, ${DateFormat('HH:mm').format(date)}';
  if (targetDate == yesterday) {
    return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
  }
  return DateFormat('MMMM d, yyyy').format(date);
}

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

    final confirmed = await AppDialogs.showDelete(
      context: context,
      title: 'Delete Monthly Budget',
      content:
          'Are you sure you want to delete this month\'s total budget? This will remove your main balance constraint.',
    );

    if (confirmed == true && context.mounted) {
      await budgetVM.deleteBudget(
          budgetId: currentBudgetEntity.id, userId: userId);
      await walletVM.refreshBudgetProgress();
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _navigateToEditBudget(BuildContext context) {
    final budgetState = budgetVM.currentBudget;
    if (budgetState == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) =>
                    BudgetFormViewModel()..setupEditMode(budgetState.budget)),
            ChangeNotifierProvider.value(value: budgetVM),
            Provider.value(value: updateBudgetUseCase),
            Provider.value(value: deleteBudgetUseCase),
            ChangeNotifierProvider.value(value: walletVM),
          ],
          child: EditBudgetScreen(
              userId: userId, existingBudget: budgetState.budget),
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
    final String currentMonthStr = DateFormat.yMMMM().format(DateTime.now());

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
              offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(currentMonthStr,
                  style: AppTextStyles.headingMedium
                      .copyWith(color: primaryTextColor)),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          (isOverBudget ? AppColors.error : AppColors.primary)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
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
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.xs),
                  AppMoreMenuButton(
                    iconColor: secondaryTextColor,
                    actions: [
                      AppMenuAction(
                          label: 'Edit Budget',
                          value: 'edit',
                          icon: Icons.edit_outlined,
                          onTap: () => _navigateToEditBudget(context)),
                      AppMenuAction(
                          label: 'Delete',
                          value: 'delete',
                          icon: Icons.delete_outline_rounded,
                          isDestructive: true,
                          onTap: () => _handleDeleteBudget(context)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Stack(alignment: Alignment.center, children: [
            SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 10,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget ? AppColors.error : AppColors.primary))),
            Column(
              children: [
                Text('$displayPercent%',
                    style: AppTextStyles.headingMedium
                        .copyWith(color: primaryTextColor)),
                Text('SPENT',
                    style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                        letterSpacing: 0.5)),
              ],
            ),
          ]),
          const SizedBox(height: AppSizes.md),
          Text('SPENT THIS MONTH',
              style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(formatCurrency(totalSpent),
              style: AppTextStyles.headingMedium
                  .copyWith(color: primaryTextColor)),
          const SizedBox(height: AppSizes.md),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Budget',
                      style: AppTextStyles.bodyNormal
                          .copyWith(color: secondaryTextColor)),
                  Text(formatCurrency(totalBudget),
                      style: AppTextStyles.bodyNormal.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Remaining',
                      style: AppTextStyles.bodyNormal
                          .copyWith(color: secondaryTextColor)),
                  Text('$daysLeft days left',
                      style: AppTextStyles.bodyNormal.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
