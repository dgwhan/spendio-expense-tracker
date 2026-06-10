import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class GoalProgressInfo extends StatelessWidget {
  final double progress; // Giá trị từ 0.0 -> 1.0
  final Color progressColor;

  const GoalProgressInfo({
    super.key,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final String percentageText = '${(progress * 100).toInt()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          percentageText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: progressColor,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceSecondaryLight,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}
