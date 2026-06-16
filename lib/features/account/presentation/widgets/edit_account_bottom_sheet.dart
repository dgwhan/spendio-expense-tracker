import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_form_bottom_sheet.dart';

class EditAccountBottomSheet extends StatelessWidget {
  final AccountViewModel viewModel;
  final AccountEntity account;

  const EditAccountBottomSheet({
    super.key,
    required this.viewModel,
    required this.account,
  });

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
      account: account,
      title: 'Edit Account',
      actionLabel: 'Update',
      onSubmit: (name, type, balance) async {
        final icon = _getDefaultIcon(type);

        final updatedAccount = AccountEntity(
          id: account.id,
          userId: account.userId,
          name: name,
          type: type,
          balance: balance,
          currencyCode: account.currencyCode,
          icon: icon,
          createdAt: account.createdAt,
          updatedAt: DateTime.now(),
          deletedAt: account.deletedAt,
        );

        final messenger = ScaffoldMessenger.of(context);

        try {
          final localId = account.userId;
          final currentUser = FirebaseAuth.instance.currentUser;
          final String remoteUid = currentUser?.uid ?? '';

          final success = await viewModel.updateAccount(
            localId,
            remoteUid,
            updatedAccount,
          );

          if (success) {
            messenger.removeCurrentSnackBar();
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Account updated successfully!',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );

            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          } else {
            if (viewModel.updateAccountError != null) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(viewModel.updateAccountError!),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        } catch (e) {
          debugPrint(
              '[Edit Account Sheet] Failed to execute update pipeline: $e');
        }
      },
    );
  }
}
