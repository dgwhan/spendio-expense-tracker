import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class AccountDetailFilterCapsule extends StatelessWidget {
  final String activeRangeDisplay;

  /// Callback khi user chọn một preset nhanh (Today, This Month, v.v.)
  final ValueChanged<String> onPresetSelected;

  /// Callback riêng khi user nhấn vào nút chọn ngày tùy chỉnh (Custom Range)
  final VoidCallback onCustomRangeTap;

  const AccountDetailFilterCapsule({
    super.key,
    required this.activeRangeDisplay,
    required this.onPresetSelected,
    required this.onCustomRangeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final List<Map<String, dynamic>> filterPresets = [
      {'label': 'Last 30 Days', 'icon': Icons.history},
      {'label': 'Today', 'icon': Icons.today},
      {'label': 'This Month', 'icon': Icons.calendar_month},
      {'label': 'Last Month', 'icon': Icons.calendar_view_month},
      {'label': 'This Year', 'icon': Icons.analytics},
    ];

    return PopupMenuButton<String>(
      tooltip: 'Select date range',
      onSelected: (value) {
        if (value == 'custom') {
          onCustomRangeTap();
        } else {
          onPresetSelected(value);
        }
      },
      offset: const Offset(0, 46),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      // FIX LỖI TẠI ĐÂY: Thay 'backgroundColor' bằng 'color' để set màu nền cho PopupMenu
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceSecondaryDark
              : AppColors.surfaceSecondaryLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              activeRangeDisplay,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return [
          ...filterPresets.map((preset) {
            final isCurrentActive = activeRangeDisplay == preset['label'];
            return PopupMenuItem<String>(
              value: preset['label'],
              height: 42,
              child: Row(
                children: [
                  Icon(
                    preset['icon'] as IconData,
                    size: 18,
                    color: isCurrentActive
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Text(
                    preset['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isCurrentActive ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentActive
                          ? AppColors.primary
                          : primaryTextColor,
                    ),
                  ),
                  if (isCurrentActive) ...[
                    const Spacer(),
                    const Icon(Icons.check_circle,
                        size: 16, color: AppColors.primary),
                  ]
                ],
              ),
            );
          }),
          PopupMenuDivider(
            height: 1,
            thickness: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          PopupMenuItem<String>(
            value: 'custom',
            height: 44,
            child: Row(
              children: [
                Icon(
                  Icons.date_range_rounded,
                  size: 18,
                  color: activeRangeDisplay.contains('...') ||
                          activeRangeDisplay == 'Custom Range...'
                      ? AppColors.primary
                      : mutedTextColor,
                ),
                const SizedBox(width: AppSizes.md),
                Text(
                  'Custom Range...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: activeRangeDisplay.contains('...')
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: activeRangeDisplay.contains('...')
                        ? AppColors.primary
                        : primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}
