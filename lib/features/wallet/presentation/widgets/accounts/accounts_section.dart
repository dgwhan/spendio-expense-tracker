import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_item_card.dart';
import 'package:spend_io_app/shared/headers/app_section_header.dart';
import 'package:spend_io_app/shared/states/section_empty_state.dart';

class AccountsSection extends StatelessWidget {
  final List<AccountEntity> accounts;
  final VoidCallback onViewAll;
  final Function(AccountEntity)? onAccountTap;

  const AccountsSection({
    super.key,
    required this.accounts,
    required this.onViewAll,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: 'My Accounts',
              fontSize: 26,
              actionLabel: 'View All',
              onActionTap: onViewAll,
            ),
            const SizedBox(height: AppSizes.lg),
            SectionEmptyState(
              title: 'No Accounts Yet',
              subtitle: 'Add your first account\nto start tracking money.',
              icon: Icons.account_balance_wallet_outlined,
              actionLabel: 'Add Your First Account',
              onActionTap: onViewAll,
            ),
          ],
        ),
      );
    }

    final displayLimit = accounts.length > 3 ? 3 : accounts.length;
    final showMoreIndicator = accounts.length > 3;
    final childCount = 1 + displayLimit + (showMoreIndicator ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.lg),
              child: AppSectionHeader(
                title: 'My Accounts',
                fontSize: 26,
                actionLabel: 'View All',
                onActionTap: onViewAll,
              ),
            );
          }

          if (index <= displayLimit) {
            final account = accounts[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: AccountItemCard(
                account: account,
                onTap: () => onAccountTap?.call(account),
              ),
            );
          }

          // More indicator
          final remaining = accounts.length - 3;
          return Padding(
            padding: const EdgeInsets.only(top: AppSizes.xs, bottom: AppSizes.lg),
            child: InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+$remaining more account${remaining > 1 ? "s" : ""}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: childCount,
      ),
    );
  }
}

