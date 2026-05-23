import 'package:flutter/material.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';

/// application route controller
class AppRouter extends StatelessWidget {
  const AppRouter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}