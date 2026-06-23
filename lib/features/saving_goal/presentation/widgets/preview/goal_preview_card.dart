import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class GoalPreviewCard extends StatelessWidget {
  final String title;
  final double targetAmount;
  final double initialAmount;
  final int colorValue;
  final int iconCodePoint;
  final String currencyCode;

  const GoalPreviewCard({
    super.key,
    required this.title,
    required this.targetAmount,
    required this.initialAmount,
    required this.colorValue,
    required this.iconCodePoint,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);

    final double progress = targetAmount <= 0
        ? 0.0
        : (initialAmount / targetAmount).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(
                  IconData(
                    iconCodePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: color,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  title.trim().isEmpty ? 'New Saving Goal' : title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: color,
            backgroundColor: color.withValues(alpha: 0.12),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatCurrency(initialAmount, currencyCode: currencyCode, locale: context.currencyContext.locale),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatCurrency(targetAmount, currencyCode: currencyCode, locale: context.currencyContext.locale),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
