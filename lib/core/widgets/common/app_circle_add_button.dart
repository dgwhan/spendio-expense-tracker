import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class AppCircleAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const AppCircleAddButton({
    super.key,
    required this.onTap,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: Icon(
          Icons.add_circle_outline_rounded,
          size: size,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
