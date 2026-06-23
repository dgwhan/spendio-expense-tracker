import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/theme/text_styles.dart';
import 'package:spend_io_app/core/widgets/button/app_button.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 60),
                  _buildIllustration(),
                  const SizedBox(height: 32),
                  Text(
                    'Smart finance\nmade simple',
                    textAlign: TextAlign.center,
                    style: TextStyles.heading1(
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Clean finance, clear mind.',
                    textAlign: TextAlign.center,
                    style: TextStyles.bodyLarge(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
              Column(
                children: [
                  AppButton(
                    title: 'Register',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    title: 'Login',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Center(
      child: Image.asset(
        'assets/images/wallet.png',
        height: 140,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 72,
              color: AppColors.primary,
            ),
          );
        },
      ),
    );
  }
}
