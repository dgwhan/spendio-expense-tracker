import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class PulseInsightCard extends StatelessWidget {
  final String highestDay;
  final double highestAmount;
  final String topCategory;
  final int topCategoryPercent;

  const PulseInsightCard({
    super.key,
    required this.highestDay,
    required this.highestAmount,
    required this.topCategory,
    required this.topCategoryPercent,
  });

  @override
  Widget build(BuildContext context) {
    final amountStr = CurrencyFormatter.format(highestAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INSIGHTS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMutedLight,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimaryLight,
                    height: 1.4,
                  ),
              children: [
                const TextSpan(text: 'Highest spending was '),
                TextSpan(
                  text: highestDay,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ($amountStr). Top category is '),
                TextSpan(
                  text: '$topCategory ($topCategoryPercent%)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
