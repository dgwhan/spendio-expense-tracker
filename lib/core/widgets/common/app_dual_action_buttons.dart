import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/primary_button.dart';

class AppDualActionButtons extends StatelessWidget {
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final AppButtonVariant primaryVariant;
  final AppButtonVariant secondaryVariant;

  const AppDualActionButtons({
    super.key,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.primaryVariant = AppButtonVariant.primary,
    this.secondaryVariant = AppButtonVariant.cancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // left action button
        Expanded(
          child: AppButton(
            title: primaryLabel,
            variant: primaryVariant,
            onPressed: onPrimaryPressed,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        // right action button
        Expanded(
          child: AppButton(
            title: secondaryLabel,
            variant: secondaryVariant,
            onPressed: onSecondaryPressed,
          ),
        ),
      ],
    );
  }
}
