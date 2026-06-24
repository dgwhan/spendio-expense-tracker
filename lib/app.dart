import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'core/theme/app_theme.dart';

class SpendIOApp extends StatefulWidget {
  const SpendIOApp({super.key});

  @override
  State<SpendIOApp> createState() => _SpendIOAppState();
}

class _SpendIOAppState extends State<SpendIOApp> {
  bool _budgetLinkWired = false;

  void _wireBudgetRefreshLink(BuildContext context) {
    if (_budgetLinkWired) return;

    final transactionVM = context.read<TransactionViewModel>();
    final budgetVM = context.read<BudgetViewModel>();
    final walletVM = context.read<WalletViewModel>();
    final accountVM = context.read<AccountViewModel>();

    transactionVM.onTransactionBalanceChanged = (userId) async {
      await budgetVM.loadBudget(userId);
      await walletVM.refreshBudgetProgress();
      await accountVM.loadAccounts(userId, userId.toString(), forceRefresh: true);
    };

    _budgetLinkWired = true;
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spend IO',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: profileVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      builder: (context, child) {
        _wireBudgetRefreshLink(context);
        return child!;
      },
    );
  }
}
