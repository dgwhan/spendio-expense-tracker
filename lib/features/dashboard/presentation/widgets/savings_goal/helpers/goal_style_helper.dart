import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class GoalStyleHelper {
  GoalStyleHelper._();

  static Map<String, dynamic> getIconStyle(String iconType) {
    switch (iconType) {
      case 'finance':
        return {
          'icon': Icons.account_balance_wallet_outlined,
          'color': AppColors.success,
          'bgColor': AppColors.success.withValues(alpha: 0.1),
        };
      case 'vehicle':
        return {
          'icon': Icons.directions_car_filled_outlined,
          'color': AppColors.warning,
          'bgColor': AppColors.warning.withValues(alpha: 0.1),
        };
      default:
        return {
          'icon': Icons.savings_outlined,
          'color': AppColors.primary,
          'bgColor': AppColors.primary.withValues(alpha: 0.1),
        };
    }
  }

  static Map<String, Color> getStatusColors(String status) {
    switch (status) {
      case 'GREAT PROGRESS':
      case 'ON TRACK':
        return {
          'text': AppColors.success,
          'bg': AppColors.success.withValues(alpha: 0.1),
        };
      default:
        return {
          'text': AppColors.textSecondaryLight,
          'bg': AppColors.surfaceSecondaryLight,
        };
    }
  }
}
