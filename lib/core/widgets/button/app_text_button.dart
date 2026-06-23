import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/theme/text_styles.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyles.button(
      color: color ?? AppColors.primary,
      fontWeight: fontWeight,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      splashColor: (color ?? AppColors.primary).withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Text(
          text,
          style: fontSize != null
              ? baseStyle.copyWith(fontSize: fontSize)
              : baseStyle,
        ),
      ),
    );
  }
}
