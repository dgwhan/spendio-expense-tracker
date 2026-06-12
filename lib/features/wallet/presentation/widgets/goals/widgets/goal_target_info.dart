import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class GoalTargetInfo extends StatelessWidget {
  final double currentAmount;
  final double targetAmount;

  const GoalTargetInfo({
    super.key,
    required this.currentAmount,
    required this.targetAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          CurrencyFormatter.format(currentAmount),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        Text(
          'Target ${CurrencyFormatter.format(targetAmount)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
