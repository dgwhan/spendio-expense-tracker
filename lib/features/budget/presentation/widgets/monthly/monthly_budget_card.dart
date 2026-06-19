import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/delete_budget_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/presentation/screens/budget_detail_screen.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';

class MonthlyBudgetCard extends StatelessWidget {
  final double totalSpent;
  final double totalBudget;
  final double remaining;
  final double percentage;
  final int daysLeft;
  final int userId;
  final VoidCallback? onTap;

  const MonthlyBudgetCard({
    super.key,
    required this.totalSpent,
    required this.totalBudget,
    required this.remaining,
    required this.percentage,
    required this.daysLeft,
    required this.userId,
    this.onTap,
  });

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

    final isOverBudget = remaining < 0;
    final progressColor = isOverBudget ? AppColors.error : AppColors.primary;

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowNatural1,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
          onTap: () async {
            debugPrint(
                '[NAVIGATION]: Intercepting card touch down pipeline. Synchronizing state values.');

            final budgetVM = context.read<BudgetViewModel>();
            final walletVM = context.read<WalletViewModel>();
            final updateUseCase = context.read<UpdateBudgetUseCase>();
            final deleteUseCase = context.read<DeleteBudgetUseCase>();

            await budgetVM.loadBudget(userId);

            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: budgetVM),
                      ChangeNotifierProvider.value(value: walletVM),
                      Provider.value(value: updateUseCase),
                      Provider.value(value: deleteUseCase),
                    ],
                    child: BudgetDetailScreen(
                      totalSpent: totalSpent,
                      totalBudget: totalBudget,
                      daysLeft: daysLeft,
                      userId: userId,
                    ),
                  ),
                ),
              );

              if (onTap != null) {
                onTap!();
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining Budget',
                      style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm, vertical: AppSizes.xs),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceSecondaryDark
                            : AppColors.surfaceSecondaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        '$daysLeft days left',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: progressColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  formatCurrency(remaining),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isOverBudget ? AppColors.error : AppColors.success,
                  ),
                ),
                if (isOverBudget)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.xs),
                    child: Text(
                      'You are over budget by ${formatCurrency(remaining.abs())}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                const SizedBox(height: AppSizes.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? AppColors.surfaceSecondaryDark
                        : AppColors.surfaceSecondaryLight,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spent',
                            style:
                                TextStyle(fontSize: 12, color: mutedTextColor)),
                        const SizedBox(height: 2),
                        Text(
                          formatCurrency(totalSpent),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Budget',
                            style:
                                TextStyle(fontSize: 12, color: mutedTextColor)),
                        const SizedBox(height: 2),
                        Text(
                          formatCurrency(totalBudget),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
