import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/primary_button.dart';

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

    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final iconColor =
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
            .withValues(alpha: 0.35);

    // bordered variant Look
    if (isBordered) {
      final cardBgColor = isDark
          ? AppColors.surfaceSecondaryDark.withValues(alpha: 0.5)
          : AppColors.surfaceLight.withValues(alpha: 0.5);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // state icon
            Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
            const SizedBox(height: AppSizes.xs),

            // title
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(color: titleColor),
            ),

            // subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: subtitleColor,
                    height: 1.2,
                  ),
                ),
              ),
            ],

            // action button
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(height: AppSizes.sm),
              AppButton(
                title: actionLabel!,
                onPressed: onActionTap,
              ),
            ],
          ],
        ),
      );
    }

    // default full screen view look
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // state icon
            Icon(
              icon,
              size: 56,
              color: iconColor,
            ),
            const SizedBox(height: AppSizes.sm),

            // title
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(
                color: titleColor,
              ),
            ),

            // subtitle
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: subtitleColor,
                  height: 1.3,
                ),
              ),
            ],

            // action button
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(height: AppSizes.lg),
              AppButton(
                title: actionLabel!,
                onPressed: onActionTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
