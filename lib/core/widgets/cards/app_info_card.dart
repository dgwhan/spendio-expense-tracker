import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class AppInfoItem {
  final String label;
  final String value;
  final Color? valueColor;

  AppInfoItem({
    required this.label,
    required this.value,
    this.valueColor,
  });
}

class AppInfoCard extends StatelessWidget {
  final String title;
  final String mainBalance;
  final List<AppInfoItem> items;
  final String? statusLabel;
  final Widget? trailingIcon;

  const AppInfoCard({
    super.key,
    required this.title,
    required this.mainBalance,
    required this.items,
    this.statusLabel,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: (isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight)
                      .withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (statusLabel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel!,
                        style: const TextStyle(
                          color: AppColors.textPrimaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (trailingIcon != null)
                trailingIcon!,
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mainBalance,
            style: TextStyle(
              color: isDarkMode ? AppColors.textPrimaryDark : Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: (isDarkMode ? AppColors.dividerDark : AppColors.dividerLight)
                .withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label.toUpperCase(),
                      style: TextStyle(
                        color: (isDarkMode
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight)
                            .withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.value,
                      style: TextStyle(
                        color: item.valueColor ??
                            (isDarkMode
                                ? AppColors.textPrimaryDark
                                : Colors.white),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
