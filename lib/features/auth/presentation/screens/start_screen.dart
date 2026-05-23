import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Clean, minimalistic authentication selection screen for Spendio.
class StartScreen extends StatelessWidget {
  const StartScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure background layout matching design
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Centered Wallet Illustration
              Center(
                child: Image.asset(
                  'assets/images/wallet.png', 
                  height: 140,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    //fallback if not have img
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Title Headline
              const Text(
                'Smart finance\nmade simple',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle Description
              const Text(
                'Clean finance, clear mind.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF524F55), // Secondary text token
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 2),

              // Banana UI Page Indicators Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEEFF3), // Unselected soft indicator state
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEEFF3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEEFF3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Action Button Stack
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

              SizedBox(
                width: double.infinity,
                height: 56, // Soft 8pt standard button height grid
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
                    backgroundColor: AppColors.primary.withOpacity(0.12), // Clean soft tint button surface
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Smooth signature corner profile
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}