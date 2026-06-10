import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import '../../../domain/entities/financial_health_status.dart';

class FinancialHealthBadge extends StatelessWidget {
  final FinancialHealthStatus status;

  const FinancialHealthBadge({
    super.key,
    required this.status,
  });

  Color _contentColor() {
    switch (status) {
      case FinancialHealthStatus.excellent:
        return AppColors.success;
      case FinancialHealthStatus.good:
        return AppColors.info;
      case FinancialHealthStatus.warning:
        return AppColors.warning;
      case FinancialHealthStatus.critical:
        return AppColors.error;
    }
  }

  String _label() {
    switch (status) {
      case FinancialHealthStatus.excellent:
        return 'Excellent';
      case FinancialHealthStatus.good:
        return 'Good';
      case FinancialHealthStatus.warning:
        return 'Warning';
      case FinancialHealthStatus.critical:
        return 'Critical';
    }
  }

  IconData _iconData() {
    switch (status) {
      case FinancialHealthStatus.excellent:
      case FinancialHealthStatus.good:
        return Icons.check_circle;
      case FinancialHealthStatus.warning:
        return Icons.warning;
      case FinancialHealthStatus.critical:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _contentColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconData(), size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            _label(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
