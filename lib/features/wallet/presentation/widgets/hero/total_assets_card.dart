import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/wallet/domain/entities/financial_health_status.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/hero/financial_health_badge.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/hero/statistics_row.dart';

class TotalAssetsCard extends StatelessWidget {
  final WalletSummaryEntity summary;
  final FinancialHealthStatus healthStatus;

  final String locale;
  final String currencyCode;

  const TotalAssetsCard({
    super.key,
    required this.summary,
    required this.healthStatus,
    this.locale = 'en_US',
    this.currencyCode = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Assets',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
              ),
              FinancialHealthBadge(status: healthStatus),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            CurrencyFormatter.format(summary.totalAssets,
                locale: locale, currencyCode: currencyCode),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
          ),
          const SizedBox(height: AppSizes.lg),
          Container(
            height: 1,
            color: AppColors.surfaceLight.withOpacity(0.15),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: StatisticsRow(
                  title: 'Monthly Budget',
                  value: CurrencyFormatter.compact(summary.monthlyBudget,
                      locale: locale, currencyCode: currencyCode),
                  isOverDarkBackground: true,
                ),
              ),
              Expanded(
                child: StatisticsRow(
                  title: 'Total Saved',
                  value: CurrencyFormatter.compact(summary.totalSaved,
                      locale: locale, currencyCode: currencyCode),
                  isOverDarkBackground: true,
                ),
              ),
              Expanded(
                child: StatisticsRow(
                  title: 'Active Goals',
                  value: summary.activeGoals.toString(),
                  isOverDarkBackground: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
