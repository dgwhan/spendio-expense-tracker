import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/button/app_action_button.dart';

class AppDualActionButtons extends StatelessWidget {
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final AppActionButtonVariant primaryVariant;
  final AppActionButtonVariant secondaryVariant;

  const AppDualActionButtons({
    super.key,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.primaryVariant = AppActionButtonVariant.primary,
    this.secondaryVariant = AppActionButtonVariant.cancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // left action button
        Expanded(
          child: AppActionButton(
            title: primaryLabel,
            variant: primaryVariant,
            onPressed: onPrimaryPressed,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        // right action button
        Expanded(
          child: AppActionButton(
            title: secondaryLabel,
            variant: secondaryVariant,
            onPressed: onSecondaryPressed,
          ),
        ),
      ],
    );
  }
}
