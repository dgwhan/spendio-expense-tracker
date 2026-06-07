import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/presentation/widgets/financial_pulse/helpers/pulse_color_helper.dart';

class PulseDayItem extends StatelessWidget {
  final String dayName;
  final double densityRatio;

  const PulseDayItem({
    super.key,
    required this.dayName,
    required this.densityRatio,
  });

  @override
  Widget build(BuildContext context) {
    final blockColor = PulseColorHelper.getHeatmapColor(densityRatio);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: blockColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dayName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
