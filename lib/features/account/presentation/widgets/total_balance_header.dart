import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class TotalBalanceHeader extends StatelessWidget {
  final double totalBalance;

  const TotalBalanceHeader({
    super.key,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceSecondaryDark
            : AppColors.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOTAL ASSETS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color:
                  isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            CurrencyFormatter.format(totalBalance),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color:
                  isDark ? AppColors.textPrimaryDark : const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
