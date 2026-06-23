import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_form.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

class AddAccountScreen extends StatelessWidget {
  final AccountViewModel viewModel;

  const AddAccountScreen({super.key, required this.viewModel});

  // get default icon
  IconData _getDefaultIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.wallet;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.eWallet:
        return Icons.account_balance_wallet;
      case AccountType.creditCard:
        return Icons.credit_card;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
        title: 'Create New Account',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.md),

              // account form context layout
              AccountForm(
                title: 'Account Details',
                actionLabel: 'Create',
                onSubmit: (name, type, balance, currencyCode) async {
                  final icon = _getDefaultIcon(type);

                  // cache context instances safely before async gap
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  // session user parsing
                  final authProvider = context.read<AuthProvider>();
                  final currentUserEntity =
                      authProvider.currentUser?.toEntity();
                  final int activeLocalUserId = currentUserEntity?.id ?? 0;

                  if (activeLocalUserId <= 0) {
                    messenger.removeCurrentSnackBar();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Critical Session Error: Access denied due to unauthenticated user session.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  final String resolvedCurrency = currencyCode;

                  final newAccount = AccountEntity(
                    id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
                    userId: activeLocalUserId,
                    name: name,
                    type: type,
                    balance: balance,
                    currencyCode: resolvedCurrency,
                    icon: icon,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  try {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final String remoteUid = currentUser?.uid ?? '';

                    final success = await viewModel.createAccount(
                      activeLocalUserId,
                      remoteUid,
                      newAccount,
                    );

                    if (success) {
                      messenger.removeCurrentSnackBar();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Account created successfully!',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // safe pop context navigate
                      navigator.pop(true);
                    }
                  } catch (e) {
                    debugPrint(
                        '[Add Account Screen] Failed to execute creation pipeline: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
