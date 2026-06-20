import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_item_card.dart';
import 'package:spend_io_app/core/widgets/common/app_empty_state.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    // Tính toán số lượng tài khoản hiển thị (tối đa 3) và số dư còn lại
    final displayLimit = accounts.length > 3 ? 3 : accounts.length;
    final displayAccounts = accounts.take(displayLimit).toList();
    final remaining = accounts.length - displayLimit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Accounts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                ),
              ),
              IconButton(
                onPressed: onViewAll,
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // BODY: Hiển thị Empty State hoặc Danh sách tài khoản
          if (accounts.isEmpty)
            AppEmptyState(
              title: 'No Accounts Yet',
              subtitle: 'Add your first account\nto start tracking money.',
              icon: Icons.account_balance_wallet_outlined,
              actionLabel: 'Add Your First Account',
              onActionTap: onViewAll,
              isBordered: true,
            )
          else ...[
            // Danh sách tối đa 3 tài khoản đầu tiên
            ...displayAccounts.map((account) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.md),
                  child: AccountItemCard(
                    account: account,
                    onTap: () => onAccountTap?.call(account),
                  ),
                )),

            // Nút xem thêm tài khoản còn lại (nếu nhiều hơn 3)
            if (remaining > 0)
              Padding(
                padding: const EdgeInsets.only(
                    top: AppSizes.xs, bottom: AppSizes.xs),
                child: InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
              ),
          ],
        ],
      ),
    );
  }
}
