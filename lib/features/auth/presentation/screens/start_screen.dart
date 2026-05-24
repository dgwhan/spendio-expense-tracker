import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
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
            children: [
              const Spacer(flex: 3),

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

              const Spacer(flex: 2),

              const _PageIndicator(),

              const Spacer(flex: 2),

              PrimaryButton(
                title: 'Register',
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

              _buildLoginButton(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Center(
      child: Image.asset(
        'images/wallet.png',
        height: 140,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
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

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Login',
          style: TextStyles.button(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _activeDot(),
        const SizedBox(width: 6),
        _inactiveDot(),
        const SizedBox(width: 6),
        _inactiveDot(),
        const SizedBox(width: 6),
        _inactiveDot(),
      ],
    );
  }

  Widget _activeDot() {
    return Container(
      width: 28,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _inactiveDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        shape: BoxShape.circle,
      ),
    );
  }
}