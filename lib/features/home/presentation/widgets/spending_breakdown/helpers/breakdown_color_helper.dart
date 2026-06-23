import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';

class BreakdownColorHelper {
  BreakdownColorHelper._();

  static Color getColor(BuildContext context, String name) {
    try {
      final categories = context.read<CategoryViewModel>().state.categories;
      final match = categories.firstWhere(
        (c) => c.name.toLowerCase().trim() == name.toLowerCase().trim(),
      );
      return Color(match.colorValue);
    } catch (_) {
      // Fallback colors matching defaults or generic color palette
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
}
