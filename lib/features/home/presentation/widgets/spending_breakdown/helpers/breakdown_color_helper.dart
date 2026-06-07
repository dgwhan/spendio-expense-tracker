import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class BreakdownColorHelper {
  BreakdownColorHelper._();

  static Color getColor(String name) {
    switch (name) {
      case 'Food & Drink':
        return AppColors.warning;
      case 'Transport':
        return AppColors.primary;
      case 'Entertainment':
        return AppColors.investment;
      default:
        return AppColors.textMutedLight;
    }
  }
}
