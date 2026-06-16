import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_form_bottom_sheet.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

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

        // Fetch the authentic internal app auth state provider cleanly now
        final authProvider = context.read<AuthProvider>();
        final int activeLocalUserId = authProvider.currentUser?.id ?? 0;

        if (activeLocalUserId <= 0) {
          messenger.removeCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                  'Critical Session Error: Access denied due to unauthenticated user session.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

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
          userId: activeLocalUserId,
          name: name,
          type: type,
          balance: balance,
          currencyCode: currentDbCurrency,
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
          debugPrint(
              '[Add Account Sheet] Failed to execute creation pipeline: $e');
        }
      },
    );
  }
}
