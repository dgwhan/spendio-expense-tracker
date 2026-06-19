import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class DateGroupHeader extends StatelessWidget {
  final String dateKey;
  const DateGroupHeader({super.key, required this.dateKey});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    String label;
    if (target == today) {
      label = 'TODAY - ${DateFormat('MMMM d').format(date).toUpperCase()}';
    } else if (target == yesterday) {
      label = 'YESTERDAY - ${DateFormat('MMMM d').format(date).toUpperCase()}';
    } else {
      label = DateFormat('MMMM d').format(date).toUpperCase();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
