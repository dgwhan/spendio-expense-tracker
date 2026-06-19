import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'core/theme/app_theme.dart';

/// root application widget
class SpendIOApp extends StatefulWidget {
  const SpendIOApp({
    super.key,
  });

  @override
  State<SpendIOApp> createState() => _SpendIOAppState();
}

class _SpendIOAppState extends State<SpendIOApp> {
  bool _budgetLinkWired = false;

  // Noi TransactionViewModel voi BudgetViewModel sau khi ca hai da ton tai
  // trong cay widget. Khong lam o tang DI (di/transaction_provider.dart)
  // de tranh dependency cycle giua module Transaction va Budget, vi
  // BudgetProgressCalculator can doc nguoc TransactionRepository.
  void _wireBudgetRefreshLink(BuildContext context) {
    if (_budgetLinkWired) return;

    final transactionVM = context.read<TransactionViewModel>();
    final budgetVM = context.read<BudgetViewModel>();

    transactionVM.onTransactionBalanceChanged = (userId) async {
      await budgetVM.loadBudget(userId);
    };

    _budgetLinkWired = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spend IO',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      builder: (context, child) {
        _wireBudgetRefreshLink(context);
        return child!;
      },

      // home: ChangeNotifierProvider(
      //   create: (_) => NavigationProvider(),
      //   child: const NavigationShell(),
      // ),
    );
  }
}
