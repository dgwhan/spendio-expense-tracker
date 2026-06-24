import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/startup/startup_coordinator.dart';
import 'package:spend_io_app/core/startup/startup_result.dart';

import 'package:spend_io_app/features/auth/presentation/screens/start_screen.dart';
import 'package:spend_io_app/features/navigation/presentation/screens/navigation_entry.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/onboarding_flow_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _started = false;

  void _log(String msg) {
    debugPrint("[SPLASH] $msg");
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  Future<void> _start() async {
    if (_started) return;
    _started = true;

    _log("Splash start...");

    await Future.delayed(Duration.zero);

    if (!mounted) return;

    final coordinator = context.read<StartupCoordinator>();

    final startTime = DateTime.now();

    final result = await coordinator.resolve(context);

    final elapsed = DateTime.now().difference(startTime);
    const minDuration = Duration(seconds: 3);

    if (elapsed < minDuration) {
      final wait = minDuration - elapsed;
      _log("Enforcing splash min duration: $wait");
      await Future.delayed(wait);
    }

    if (!mounted) return;

    _log("Navigation result: $result");

    _navigate(result, coordinator);
  }

  void _navigate(
    StartupResult result,
    StartupCoordinator coordinator,
  ) {
    if (!mounted) return;

    Widget next;

    switch (result) {
      case StartupResult.login:
        next = const StartScreen();
        break;

      case StartupResult.onboarding:
        next = OnboardingFlowScreen(
          userEmail: coordinator.authProvider.currentUser?.email ?? '',
        );
        break;

      case StartupResult.home:
        next = const NavigationEntry();
        break;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ ĐÃ ĐỒNG BỘ: Sử dụng màu Primary từ hệ thống hệt như màu nền cũ của bồ
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Lottie.asset(
                'assets/animations/wallet_animation.json',
                repeat: true,
                animate: true,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Spend IO',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
