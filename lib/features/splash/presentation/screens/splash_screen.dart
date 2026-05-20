import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration: const BoxDecoration(
                shape: BoxShape.circle,

                gradient: LinearGradient(
                  colors: [
                    AppColors.gradientStart,
                    AppColors.gradientEnd,
                  ],
                ),
              ),

              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Spend IO',

              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTitle,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Smart Finance Tracker',

              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}