import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class GoalAmountInfo extends StatelessWidget {
  final double current;
  final double target;

  const GoalAmountInfo({
    super.key,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          CurrencyFormatter.format(current),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
        ),
        Text(
          ' / ${CurrencyFormatter.format(target)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMutedLight,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
