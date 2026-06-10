import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/date_formatter.dart';

class WalletHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onGenerateReport;

  const WalletHeader({
    super.key,
    required this.selectedMonth,
    required this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              DateFormatter.toMonthYearString(selectedMonth),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMutedLight,
                  ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: onGenerateReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surfaceLight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Generate Report',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
