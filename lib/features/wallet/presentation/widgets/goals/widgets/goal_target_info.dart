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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          CurrencyFormatter.format(currentAmount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        Text(
          'Target ${CurrencyFormatter.format(targetAmount)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }
}
