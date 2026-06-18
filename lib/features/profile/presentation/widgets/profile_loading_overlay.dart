import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class ProfileLoadingOverlay extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final Color borderBoxColor;

  const ProfileLoadingOverlay({
    super.key,
    required this.isDark,
    required this.surfaceColor,
    required this.borderBoxColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.overlay,
        child: Center(
          child: Card(
            color: surfaceColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              side: BorderSide(color: borderBoxColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                backgroundColor: isDark
                    ? AppColors.surfaceSecondaryDark
                    : AppColors.surfaceSecondaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
  