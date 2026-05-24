import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';

// DATA
import 'features/auth/data/datasource/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

// DOMAIN
import 'features/auth/domain/usecases/check_email_usecase.dart';

// PRESENTATION
import 'features/auth/presentation/viewmodels/register_form_viewmodel.dart';
import 'features/auth/presentation/viewmodels/login_form_viewmodel.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // DATABASE INIT
  // =========================
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [

        // DATA LAYER
        Provider<AuthLocalDatasource>(
          create: (_) => AuthLocalDatasource(),
        ),

        ProxyProvider<AuthLocalDatasource, AuthRepositoryImpl>(
          update: (_, datasource, __) =>
              AuthRepositoryImpl(datasource),
        ),

        // USE CASES
        ProxyProvider<AuthRepositoryImpl, CheckEmailUseCase>(
          update: (_, repo, __) => CheckEmailUseCase(repo),
        ),

        // VIEWMODELS

        //register vm
        ChangeNotifierProxyProvider<CheckEmailUseCase,
            RegisterFormViewModel>(
          create: (_) => RegisterFormViewModel(
            checkEmailUseCase: _.read<CheckEmailUseCase>(),
          ),
          update: (_, useCase, vm) =>
              vm ?? RegisterFormViewModel(checkEmailUseCase: useCase),
        ),

        //login vm
        ChangeNotifierProvider(
          create: (_) => LoginFormViewModel(),
        ),

        //AUTH ACTION LAYER
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const SpendIOApp(),
    ),
  );
}