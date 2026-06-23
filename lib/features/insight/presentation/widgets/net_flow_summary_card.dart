import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_state.dart';

class NetFlowSummaryCard extends StatelessWidget {
  final InsightState state;

  const NetFlowSummaryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;
    final preferredCurrency = context.currencyContext.preferredCurrencyCode;
    final preferredLocale = context.currencyContext.locale;

    //AI summary template
    final netBalanceFormatted = formatCurrency(
      state.netBalance.abs(),
      currencyCode: preferredCurrency,
      locale: preferredLocale,
    );
    final isPositive = state.netBalance >= 0;
    
    final aiSummary = isPositive
        ? "Great job! You saved $netBalanceFormatted this period. Keep maintaining this healthy financial flow."
        : "You spent $netBalanceFormatted more than you earned. Review your category breakdown below to optimize your budget.";

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề & Trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.translate('net_flow_balance'),
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isPositive ? "Surplus" : "Deficit",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Số dư ròng lớn
              Text(
                formatCurrency(
                  state.netBalance,
                  currencyCode: preferredCurrency,
                  locale: preferredLocale,
                ),
                style: AppTextStyles.largeAmount.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              
              Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              const SizedBox(height: 20),

              // Thu nhập và Chi tiêu
              Row(
                children: [
                  Expanded(
                    child: _buildFlowSummaryItem(
                      context: context,
                      title: AppLocalizations.translate('income'),
                      amount: state.totalIncome,
                      color: AppColors.success,
                      icon: Icons.south_west_rounded,
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  Expanded(
                    child: _buildFlowSummaryItem(
                      context: context,
                      title: AppLocalizations.translate('expense'),
                      amount: state.totalExpense,
                      color: AppColors.error,
                      icon: Icons.north_east_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowSummaryItem({
    required BuildContext context,
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: AppSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatCurrency(
                amount,
                currencyCode: context.currencyContext.preferredCurrencyCode,
                locale: context.currencyContext.locale,
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
