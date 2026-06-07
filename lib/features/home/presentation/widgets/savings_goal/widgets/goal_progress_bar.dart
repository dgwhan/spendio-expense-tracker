import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class GoalProgressBar extends StatelessWidget {
  final double progress;
  final String iconType;

  const GoalProgressBar(
      {super.key, required this.progress, required this.iconType});

  @override
  Widget build(BuildContext context) {
    final Color progressColor =
        iconType == 'vehicle' ? AppColors.warning : AppColors.success;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: AppColors.surfaceSecondaryLight,
        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
      ),
    );
  }
}
