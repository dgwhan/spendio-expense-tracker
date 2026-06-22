import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/widgets/card/account_item_card.dart';
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
    final textMuted =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    // Tính toán số lượng tài khoản hiển thị (tối đa 3) và số dư còn lại
    final displayLimit = accounts.length > 3 ? 3 : accounts.length;
    final displayAccounts = accounts.take(displayLimit).toList();
    final remaining = accounts.length - displayLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER (Đồng bộ cỡ chữ 15px và bọc InkWell mượt mà) ---
        InkWell(
          onTap: onViewAll,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.translate('accounts'),
                style: TextStyle(
                  fontSize: 15, // Đồng bộ 15px mượt mà với Wallet/Budget
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: textMuted,
                size: 18,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // --- BODY: Hiển thị Empty State hoặc Danh sách tài khoản ---
        if (accounts.isEmpty)
          AppEmptyState(
            title: 'No Accounts Yet',
            subtitle: 'Add your first account\nto start tracking money.',
            icon: Icons.account_balance_wallet_outlined,
            actionLabel: 'Add Your First Account',
            onActionTap: onViewAll,
            isBordered:
                false, // Tắt luôn border của empty state nếu có flag này
          )
        else ...[
          // Danh sách tối đa 3 tài khoản đầu tiên
          ...displayAccounts.map((account) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 10), // Giảm spacing mượt hơn
                child: AccountItemCard(
                  account: account,
                  onTap: () => onAccountTap?.call(account),
                ),
              )),

          // Nút xem thêm tài khoản còn lại (nếu nhiều hơn 3)
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+$remaining more account${remaining > 1 ? "s" : ""}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
