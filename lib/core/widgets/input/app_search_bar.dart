import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

/// [App Location] Core Shared Widgets -> Inputs.
/// [Core Function] Reusable custom textfield bar tailored for real-time querying and data pipeline filtering.
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceSecondaryDark
            : AppColors.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: TextField(
        controller: controller,
        style: TextStyle(color: primaryTextColor),
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: mutedTextColor),
          hintText: hintText,
          hintStyle: TextStyle(color: mutedTextColor.withValues(alpha: 0.7)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
