import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';

class AppFormTitle extends StatelessWidget {
  final String title;
  final bool isRequired;

  const AppFormTitle({
    super.key,
    required this.title,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: title,
          style: AppTextStyles.sectionTitle.copyWith(color: mutedTextColor),
          children: isRequired
              ? [
                  const TextSpan(
                      text: ' *', style: TextStyle(color: AppColors.error))
                ]
              : [],
        ),
      ),
    );
  }
}
