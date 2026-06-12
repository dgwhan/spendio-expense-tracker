import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final double? fontSize;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget? trailing;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.fontSize,
    this.actionLabel,
    this.onActionTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (trailing != null)
          trailing!
        else if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
