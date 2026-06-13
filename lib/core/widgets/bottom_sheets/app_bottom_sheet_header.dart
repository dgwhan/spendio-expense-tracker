import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class AppBottomSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AppBottomSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final dragHandleColor = isDark ? AppColors.borderDark : Colors.grey.shade300;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Centered Drag Handle
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: dragHandleColor,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        
        // Header Title
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        
        // Optional Subtitle
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.sm),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: mutedTextColor,
            ),
          ),
        ],
      ],
    );
  }
}
