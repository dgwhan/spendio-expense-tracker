import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

/// application entry point
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // web database factory
  if (kIsWeb) {
    databaseFactory =
        databaseFactoryFfiWeb;
  } else {
    // desktop database factory
    sqfliteFfiInit();

    databaseFactory =
        databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],

      child: const SpendIOApp(),
    ),
  );
}