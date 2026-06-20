import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class AppScreenTitle extends StatelessWidget {
  final String title;
  final bool isCenter;
  final Color? color;

  const AppScreenTitle({
    super.key,
    required this.title,
    this.isCenter = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final finalColor = color ?? defaultColor;

    final textWidget = Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600, 
        color: finalColor,
      ),
    );

    if (isCenter) {
      return Center(
        child: textWidget,
      );
    }

    return textWidget;
  }
}
