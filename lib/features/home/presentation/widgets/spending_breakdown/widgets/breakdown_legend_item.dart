import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/home/data/models/spending_breakdown_model.dart';
import 'package:spend_io_app/features/home/presentation/widgets/spending_breakdown/helpers/breakdown_color_helper.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class BreakdownLegendItem extends StatelessWidget {
  final SpendingItemModel item;

  const BreakdownLegendItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = BreakdownColorHelper.getColor(context, item.name);

    final cardBackgroundColor = isDark ? AppColors.surfaceDark : Colors.white;
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.surfaceSecondaryLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            CurrencyFormatter.format(
              item.amount,
              currencyCode: context.currencyContext.preferredCurrencyCode,
              locale: context.currencyContext.locale,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(item.percentage * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
          ),
        ],
      ),
    );
  }
}
