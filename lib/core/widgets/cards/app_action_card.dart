import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class AppActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;

  const AppActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final finalBgColor = backgroundColor ??
        (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight);
    final finalIconColor = iconColor ?? AppColors.primary;
    final finalTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: finalBgColor,
                  border: borderColor != null
                      ? Border.all(color: borderColor!, width: 1.5)
                      : null,
                ),
                child: Icon(
                  icon,
                  color: finalIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: finalTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
