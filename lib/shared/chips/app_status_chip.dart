import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

enum BudgetStatus {
  safe,
  warning,
  danger,
}

extension BudgetStatusExt on BudgetStatus {
  String get label {
    switch (this) {
      case BudgetStatus.safe:
        return 'SAFE';
      case BudgetStatus.warning:
        return 'WARNING';
      case BudgetStatus.danger:
        return 'DANGER';
    }
  }

  Color get codeColor {
    switch (this) {
      case BudgetStatus.safe:
        return AppColors.success;
      case BudgetStatus.warning:
        return AppColors.warning;
      case BudgetStatus.danger:
        return AppColors.error;
    }
  }

  Color get bgColor => codeColor.withValues(alpha: 0.15);
}

class AppStatusChip extends StatelessWidget {
  final BudgetStatus status;

  const AppStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.codeColor,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
