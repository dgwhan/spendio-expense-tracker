import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/data/models/financial_pulse_model.dart';
import 'pulse_day_item.dart';

class PulseHeatmap extends StatelessWidget {
  final List<DailySpendingModel> dailySpendings;

  const PulseHeatmap({super.key, required this.dailySpendings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "WEEKLY SPENDING DENSITY",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMutedLight,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dailySpendings.map((data) {
            return PulseDayItem(
              dayName: data.dayName,
              densityRatio: data.densityRatio,
            );
          }).toList(),
        ),
      ],
    );
  }
}
