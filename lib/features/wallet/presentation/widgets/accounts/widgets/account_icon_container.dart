import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class AccountIconContainer extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const AccountIconContainer({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
    );
  }
}
