import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'account_form_bottom_sheet.dart';

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
          userId: 1, // Root user ID default
          name: name,
          type: type,
          balance: balance,
          icon: icon,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        viewModel.createAccount(newAccount).then((_) {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      },
    );
  }
}
