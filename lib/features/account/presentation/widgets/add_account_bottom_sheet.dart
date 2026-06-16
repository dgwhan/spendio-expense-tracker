import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_form_bottom_sheet.dart';
import 'package:spend_io_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class AddAccountBottomSheet extends StatelessWidget {
  final AccountViewModel viewModel;

  const AddAccountBottomSheet({super.key, required this.viewModel});

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
    return AccountFormBottomSheet(
      title: 'Create New Account',
      actionLabel: 'Create',
      onSubmit: (name, type, balance) async {
        final icon = _getDefaultIcon(type);
        final messenger = ScaffoldMessenger.of(context);

        final String? currentDbCurrency = viewModel.userCurrency;

        if (currentDbCurrency == null || currentDbCurrency.trim().isEmpty) {
          messenger.removeCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                  'Unable to detect active wallet currency. Please ensure your database sync is initialized.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final newAccount = AccountEntity(
          id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
          userId: 0,
          name: name,
          type: type,
          balance: balance,
          currencyCode: currentDbCurrency,
          icon: icon,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          final localId = newAccount.userId;

          final currentUser = FirebaseAuth.instance.currentUser;
          final String remoteUid = currentUser?.uid ?? '';
          final String userEmail = currentUser?.email ?? '';

          final success = await viewModel.createAccount(
            localId,
            remoteUid,
            newAccount,
            onboardingRepo: context.read<OnboardingRepository>(),
            userEmail: userEmail,
          );

          if (success) {
            messenger.removeCurrentSnackBar();
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );

            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          }
        } catch (e) {
          debugPrint('Error when create account in: $e');
        }
      },
    );
  }
}
