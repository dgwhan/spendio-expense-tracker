import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class PulseSummary extends StatelessWidget {
  final double totalAmount;
  final double comparePercentage;
  final bool isDecreased;

  const PulseSummary({
    super.key,
    required this.totalAmount,
    required this.comparePercentage,
    required this.isDecreased,
  });

  @override
  Widget build(BuildContext context) {
    final percentStr = '${(comparePercentage * 100).toStringAsFixed(0)}%';
    final trendColor = isDecreased ? AppColors.success : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "THIS WEEK'S SPENDING",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatCurrency(
                totalAmount,
                currencyCode: context.currencyContext.preferredCurrencyCode,
                locale: context.currencyContext.locale,
              ),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
            ),
            const SizedBox(width: 8),
            // Cụm xu hướng tăng giảm kế bên số tiền
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDecreased
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      color: trendColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$percentStr compared\nto last week',
                        style: TextStyle(
                          color: trendColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
