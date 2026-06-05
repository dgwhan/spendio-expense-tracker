import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/spending_breakdown_model.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/spending_breakdown/helpers/breakdown_color_helper.dart';

class BreakdownLegendItem extends StatelessWidget {
  final SpendingItemModel item;

  const BreakdownLegendItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = BreakdownColorHelper.getColor(item.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceSecondaryLight),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            item.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
          ),
          const Spacer(),
          Text(
            CurrencyFormatter.compact(item.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(item.percentage * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
          ),
        ],
      ),
    );
  }
}
