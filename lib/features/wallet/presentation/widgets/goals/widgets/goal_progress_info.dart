import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class GoalProgressInfo extends StatelessWidget {
  final double progress;
  final Color progressColor;

  const GoalProgressInfo({
    super.key,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressBgColor = isDark ? AppColors.surfaceSecondaryDark : const Color(0xFFF0F2F5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: progressBgColor,
        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        minHeight: 10,
      ),
    );
  }
}
