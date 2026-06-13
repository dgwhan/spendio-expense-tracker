import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool isBordered;

  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onActionTap,
    this.isBordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final iconColor = (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withValues(alpha: 0.35);

    if (isBordered) {
      final cardBgColor = isDark ? AppColors.surfaceSecondaryDark.withValues(alpha: 0.5) : AppColors.surfaceLight.withValues(alpha: 0.5);
      final borderColor = isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight.withValues(alpha: 0.5);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: iconColor,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(height: AppSizes.md),
              TextButton(
                onPressed: onActionTap,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),
            ],
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(height: AppSizes.lg),
              ElevatedButton(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xl,
                    vertical: AppSizes.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
