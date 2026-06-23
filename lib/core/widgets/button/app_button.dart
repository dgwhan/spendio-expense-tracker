import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

enum AppButtonVariant { primary, secondary, destructive }

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final double height;

  const AppButton({
    super.key,
    required this.title,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color getBackgroundColor() {
      if (onPressed == null || isLoading) return AppColors.disabled;

      switch (variant) {
        case AppButtonVariant.primary:
          return AppColors.primary;
        case AppButtonVariant.secondary:
          return isDark ? AppColors.bankBgDark : AppColors.bankBgLight;
        case AppButtonVariant.destructive:
          return isDark
              ? AppColors.categoryBillsBgDark
              : AppColors.categoryBillsBgLight;
      }
    }

    Color getTextColor() {
      if (onPressed == null || isLoading) {
        return isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
      }

      switch (variant) {
        case AppButtonVariant.primary:
          return AppColors.white;
        case AppButtonVariant.secondary:
          return AppColors.primary;
        case AppButtonVariant.destructive:
          return AppColors.error; // Màu đỏ cho chữ Logout
      }
    }

    return SizedBox(
      width: double.infinity, // Kéo dài nút
      height: height,
      child: TextButton(
        onPressed: (isLoading) ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
                ),
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(),
                ),
              ),
      ),
    );
  }
}
