import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class GoalEstimatedDate extends StatelessWidget {
  final DateTime estimatedDate;

  const GoalEstimatedDate({
    super.key,
    required this.estimatedDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String formattedDate = DateFormat('MMM yyyy').format(estimatedDate);
    final textColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Text(
      'Est. Completion: $formattedDate',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );
  }
}
