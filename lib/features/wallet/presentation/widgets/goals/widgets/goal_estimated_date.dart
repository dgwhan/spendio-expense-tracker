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
    final String formattedDate = DateFormat('MMM yyyy').format(estimatedDate);

    return Text(
      'Est. Completion: $formattedDate',
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMutedLight,
      ),
    );
  }
}
