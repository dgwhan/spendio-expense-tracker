import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class PulseColorHelper {
  PulseColorHelper._();

  static Color getHeatmapColor(double ratio) {
    if (ratio <= 0.1) return AppColors.surfaceSecondaryLight;

    final double safeAlpha = ratio.clamp(0.25, 1.0);
    return AppColors.primary.withValues(alpha: safeAlpha);
  }
}
