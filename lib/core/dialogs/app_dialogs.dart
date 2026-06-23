import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/button/app_action_button.dart';
import 'package:spend_io_app/features/auth/presentation/screens/login_screen.dart';

class AppDialogs {
  AppDialogs._();

  // email exists dialog
  static Future<void> emailExists(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded,
                      color: AppColors.warning, size: 28),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Email already exists',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: -0.2),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This email address is already associated with an account. Would you like to log in instead?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF524F55), height: 1.45),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogCtx); // pop đúng hộp thoại
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Log In Now',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pop(dialogCtx), // pop đúng hộp thoại
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9099A0))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // core delete confirmation dialog phẳng cao cấp
  static Future<bool?> showDelete({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBgColor =
        isDark ? AppColors.surfaceSecondaryDark : Colors.white;
    final titleColor = isDark ? AppColors.textPrimaryDark : Colors.black;
    final bodyColor =
        isDark ? AppColors.textSecondaryDark : const Color(0xFF524F55);

    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => Dialog(
        backgroundColor: dialogBgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 28),
              ),
              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingMedium.copyWith(color: titleColor),
              ),
              const SizedBox(height: 10),

              Text(
                content,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyNormal
                    .copyWith(color: bodyColor, height: 1.4),
              ),
              const SizedBox(height: 24),

              // destructive delete action button
              SizedBox(
                width: double.infinity,
                child: AppActionButton(
                  title: 'Delete',
                  variant: AppActionButtonVariant.delete,
                  onPressed: () => Navigator.pop(dialogContext, true),
                ),
              ),
              const SizedBox(height: 8),

              // cancel fallback action button
              SizedBox(
                width: double.infinity,
                child: AppActionButton(
                  title: 'Cancel',
                  variant: AppActionButtonVariant.cancel,
                  onPressed: () => Navigator.pop(dialogContext, false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
