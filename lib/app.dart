import 'package:flutter/material.dart';
import 'package:spend_io_app/features/navigation/presentation/screens/navigation_shell.dart';
import 'package:spend_io_app/features/splash/presentation/screens/splash_screen.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

/// root application widget
class SpendIOApp extends StatelessWidget {
  const SpendIOApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spend IO',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
      // home: const NavigationShell(),
    );
  }
}
