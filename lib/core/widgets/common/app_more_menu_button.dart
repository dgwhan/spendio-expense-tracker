import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';

class AppMoreMenuButton extends StatelessWidget {
  final List<AppMenuAction> actions;
  final Color? iconColor;

  const AppMoreMenuButton({
    super.key,
    required this.actions,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: iconColor ?? Theme.of(context).iconTheme.color,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 140),
      onSelected: (value) {
        final action = actions.firstWhere((a) => a.value == value);
        action.onTap();
      },
      itemBuilder: (_) => actions
          .map((action) => PopupMenuItem(
                value: action.value,
                child: Row(
                  children: [
                    Icon(
                      action.icon,
                      size: 18,
                      color: action.isDestructive ? AppColors.error : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      action.label,
                      // SỬ DỤNG BỘ STYLE HỆ THỐNG Ở ĐÂY
                      style: AppTextStyles.bodyNormal.copyWith(
                        fontSize: 14,
                        color: action.isDestructive ? AppColors.error : null,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class AppMenuAction {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  AppMenuAction({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}
