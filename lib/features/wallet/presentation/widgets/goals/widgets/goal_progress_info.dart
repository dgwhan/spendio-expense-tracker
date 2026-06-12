import 'package:flutter/material.dart';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: const Color(0xFFF0F2F5),
        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        minHeight: 10,
      ),
    );
  }
}
