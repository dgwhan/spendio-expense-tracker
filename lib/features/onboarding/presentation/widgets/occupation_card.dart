import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';

class OccupationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const OccupationCard({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    final bool isError = viewModel.hasError;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color getBackgroundColor() {
      if (selected) {
        return AppColors.primary.withValues(alpha: 0.08);
      }
      return isDark
          ? AppColors.surfaceSecondaryDark
          : AppColors.surfaceSecondaryLight;
    }

    Color getBorderColor() {
      if (selected) return AppColors.primary;
      if (isError) {
        return AppColors.error.withValues(alpha: 0.8);
      }
      return Colors.transparent;
    }

    Color getContentColor() {
      if (selected) return AppColors.primary;
      return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: getBorderColor(),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: getContentColor(),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyNormal.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: getContentColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
