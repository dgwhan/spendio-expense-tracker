import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class DashboardSectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const DashboardSectionContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: child,
    );
  }
}
