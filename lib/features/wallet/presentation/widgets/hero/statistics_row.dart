import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class StatisticsRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isOverDarkBackground;

  const StatisticsRow({
    super.key,
    required this.title,
    required this.value,
    this.isOverDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isOverDarkBackground
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final valueColor = isOverDarkBackground
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: titleColor,
              ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
