import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'account_form_bottom_sheet.dart';

class EditAccountBottomSheet extends StatelessWidget {
  final WalletViewModel viewModel;
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
      case AccountType.savingsAccount:
        return Icons.savings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AccountFormBottomSheet(
      account: account,
      title: 'Edit Account',
      actionLabel: 'Update',
      onSubmit: (name, type, balance) {
        final icon = _getDefaultIcon(type);
        
        final updatedAccount = AccountEntity(
          id: account.id,
          userId: account.userId,
          name: name,
          type: type,
          balance: balance,
          icon: icon,
          createdAt: account.createdAt,
          updatedAt: DateTime.now(),
          deletedAt: account.deletedAt,
        );

        viewModel.updateAccount(updatedAccount).then((_) {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      },
    );
  }
}
