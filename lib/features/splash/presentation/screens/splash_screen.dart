import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/startup/startup_coordinator.dart';
import 'package:spend_io_app/core/startup/startup_result.dart';
import 'package:spend_io_app/features/auth/presentation/screens/start_screen.dart';
import 'package:spend_io_app/features/navigation/presentation/screens/navigation_entry.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/onboarding_flow_screen.dart';

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

  /// navigate based on coordinator resolution
  Future<void> startApp() async {
    final startTime = DateTime.now();

    // Giải quyết luồng định danh trạng thái User (Login / Register / Home)
    final startupCoordinator = context.read<StartupCoordinator>();
    final result = await context.read<StartupCoordinator>().resolve(context);

    // 3. Đảm bảo thời gian hiển thị Splash tối thiểu để trải nghiệm mượt mà
    final elapsed = DateTime.now().difference(startTime);
    const minDuration = Duration(seconds: 2);
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }

    if (!mounted) return;

    // 4. Điều hướng ứng dụng dựa theo kết quả startup
    switch (result) {
      case StartupResult.login:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const StartScreen(),
          ),
        );
        break;
      case StartupResult.onboarding:
        final email = startupCoordinator.authProvider.currentUser?.email ?? '';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingFlowScreen(userEmail: email),
          ),
        );
        break;
      case StartupResult.home:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const NavigationEntry(),
          ),
        );
        break;
    }
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
                color: Colors.white.withValues(alpha: 0.12),
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
