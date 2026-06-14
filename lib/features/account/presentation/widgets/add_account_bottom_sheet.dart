import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_form_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';

class AddAccountBottomSheet extends StatelessWidget {
  final WalletViewModel viewModel;

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
      case AccountType.savingsAccount:
        return Icons.savings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AccountFormBottomSheet(
      title: 'Create New Account',
      actionLabel: 'Create',
      onSubmit: (name, type, balance) {
        final icon = _getDefaultIcon(type);
        final newAccount = AccountEntity(
          id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
          userId: 1,
          name: name,
          type: type,
          balance: balance,
          icon: icon,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        Navigator.of(context, rootNavigator: true).pop(true);

        final messenger = ScaffoldMessenger.of(context);
        viewModel.createAccount(newAccount).then((_) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        });
      },
    );
  }
}
