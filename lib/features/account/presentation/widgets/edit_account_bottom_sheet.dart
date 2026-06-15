import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_form_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';

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
          icon: icon,
          createdAt: account.createdAt,
          updatedAt: DateTime.now(),
          deletedAt: account.deletedAt,
        );

        final messenger = ScaffoldMessenger.of(context);

        try {
          await viewModel.updateAccount(updatedAccount);

          messenger.showSnackBar(
            const SnackBar(
              content: Text('Account updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          if (context.mounted) {
            Navigator.of(context).pop(true);
          }
        } catch (e) {
          debugPrint('Lỗi cập nhật tài khoản: $e');
        }
      },
    );
  }
}
