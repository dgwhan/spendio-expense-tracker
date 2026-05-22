import 'dart:async';

import 'package:flutter/material.dart';

import '../../../onboarding/presentation/screens/onboarding_screen.dart';

/// initial splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    startApp();
  }

  /// navigate to onboarding
  void startApp() {
    Timer(
      const Duration(seconds: 2),
          () {
        Navigator.pushReplacement(
          context,

          MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B5FEF),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 120,
              height: 120,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Spend IO',

              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}