import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';

class WalletPickerSheet extends StatelessWidget {
  final List<AccountEntity> accounts;
  final AccountEntity? selectedAccount;
  final ValueChanged<AccountEntity> onAccountSelected;

  const WalletPickerSheet({
    super.key,
    required this.accounts,
    required this.selectedAccount,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppSizes.lg)),
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh kéo ngang thẩm mỹ
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Select Wallet / Account',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.sm),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];
                final isCurrent = selectedAccount?.id == acc.id;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.primary),
                  ),
                  title: Text(acc.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: isCurrent
                      ? const Icon(Icons.check_circle_rounded,
                          color: Colors.green)
                      : null,
                  onTap: () {
                    onAccountSelected(acc);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
