import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class MonthlyBudgetCard extends StatelessWidget {
  final double spent;
  final double budget;
  final int daysLeft;

  const MonthlyBudgetCard({
    super.key,
    required this.spent,
    required this.budget,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double progress = (budget > 0) ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final double remaining = budget - spent;

    final backgroundColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : const Color(0xFF6200EE).withValues(alpha: 0.3);
    final titleTextColor = isDark ? AppColors.textMutedDark : Colors.black45;
    final budgetLimitColor = isDark ? AppColors.textSecondaryDark : Colors.black38;
    final detailTextColor = isDark ? AppColors.textSecondaryDark : Colors.black54;
    final boldTextColor = isDark ? AppColors.textPrimaryDark : Colors.black;
    final buttonBorderColor = isDark ? AppColors.borderDark : const Color(0xFFE8EEFF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent so far',
                    style: TextStyle(
                      color: titleTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        CurrencyFormatter.format(spent),
                        style: const TextStyle(
                          color: Color(0xFF0038FF),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' / ${CurrencyFormatter.format(budget)}',
                        style: TextStyle(
                          color: budgetLimitColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: buttonBorderColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    color: Color(0xFF0038FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? AppColors.surfaceSecondaryDark : const Color(0xFFF0F2F5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF0038FF)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 18),
          Text.rich(
            TextSpan(
              text: 'You have ',
              style: TextStyle(color: detailTextColor, fontSize: 14),
              children: [
                TextSpan(
                  text: CurrencyFormatter.format(remaining),
                  style: TextStyle(
                    color: boldTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' left for the next $daysLeft days.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
