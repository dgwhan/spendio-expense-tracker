import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    // stabilize provider tree
    await Future.delayed(Duration.zero);

    final coordinator = context.read<StartupCoordinator>();

    final startTime = DateTime.now();
    final result = await coordinator.resolve(context);

    final elapsed = DateTime.now().difference(startTime);
    const minDuration = Duration(seconds: 2);

    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }

    if (!mounted) return;

    switch (result) {
      case StartupResult.login:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StartScreen()),
        );
        break;

      case StartupResult.onboarding:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingFlowScreen(
              userEmail:
                  coordinator.authProvider.currentUser?.email ?? '',
            ),
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
    return const Scaffold(
      backgroundColor: Color(0xFF5B5FEF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.12,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Spend IO',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}