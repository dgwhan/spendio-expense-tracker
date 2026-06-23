import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';

enum AppActionButtonVariant { primary, cancel, delete }

class AppActionButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final AppActionButtonVariant variant;

  const AppActionButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.variant = AppActionButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: (variant == AppActionButtonVariant.primary)
          ? _buildPrimaryButton()
          : _buildOutlinedButton(),
    );
  }

  // primary button (insert, update, edit)
  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      ),
      child: Text(
        title,
        style: AppTextStyles.buttonLabel.copyWith(color: AppColors.white),
      ),
    );
  }

  // outlined button (cancel, delete)
  Widget _buildOutlinedButton() {
    final isDelete = variant == AppActionButtonVariant.delete;
    final color = isDelete ? AppColors.error : Colors.grey;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 1.2),
        foregroundColor: color,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        title,
        style: AppTextStyles.buttonLabel.copyWith(color: color),
      ),
    );
  }
}
