import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_item_card.dart';
import 'package:spend_io_app/shared/headers/app_section_header.dart';
import 'package:spend_io_app/shared/states/section_empty_state.dart';

class AccountsSection extends StatelessWidget {
  final List<AccountEntity> accounts;
  final VoidCallback? onAddAccount;
  final Function(AccountEntity)? onAccountTap;

  const AccountsSection({
    super.key,
    required this.accounts,
    this.onAddAccount,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'My Accounts',
          fontSize: 26,
          trailing: GestureDetector(
            onTap: onAddAccount,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.sm * 1.2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        accounts.isEmpty
            ? SectionEmptyState(
                title: 'No Accounts Yet',
                subtitle: 'Add your first account\nto start tracking money.',
                icon: Icons.account_balance_wallet_outlined,
                actionLabel: 'Add Your First Account',
                onActionTap: onAddAccount,
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.md),
                    child: AccountItemCard(
                      account: account,
                      onTap: () => onAccountTap?.call(account),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
