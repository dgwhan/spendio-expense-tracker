import 'package:flutter/material.dart';

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

      themeMode: ThemeMode.light,

      home: const AppRouter(),
    );
  }
}