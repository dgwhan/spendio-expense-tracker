import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class BudgetProgressBar extends StatelessWidget {
  final double progress;
  final String budgetTitle;
  final String remainingText;
  final String usedPercentText;
  final String limitText;

  const BudgetProgressBar({
    super.key,
    required this.progress,
    required this.budgetTitle,
    required this.remainingText,
    required this.usedPercentText,
    required this.limitText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //Hàng trên: Tiêu đề và số tiền đã đặt mục tiêu/ tháng
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              budgetTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
            ),
            Text(
              remainingText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // THANH PROGRESS BAR
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.surfaceSecondaryLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),

        const SizedBox(height: 10),

        // hàng dưới bao gồm: phần trăm used và limit
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              usedPercentText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
            ),
            Text(
              limitText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
