import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/screen/add_account_screen.dart';
import 'package:spend_io_app/features/account/presentation/widgets/card/account_item_card.dart';
import 'package:spend_io_app/core/widgets/common/app_empty_state.dart';
import 'package:spend_io_app/core/widgets/common/app_circle_add_button.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';

class AccountsSection extends StatelessWidget {
  final List<AccountEntity> accounts;
  final VoidCallback onViewAll;
  final Function(AccountEntity)? onAccountTap;
  final VoidCallback? onAddAccountTap;

  const AccountsSection({
    super.key,
    required this.accounts,
    required this.onViewAll,
    this.onAccountTap,
    this.onAddAccountTap,
  });

  void _navigateToCreateAccount(BuildContext context) {
    if (onAddAccountTap != null) {
      onAddAccountTap!.call();
      return;
    }

    final accountVM = context.read<AccountViewModel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAccountScreen(viewModel: accountVM),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textMuted =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final displayLimit = accounts.length > 3 ? 3 : accounts.length;
    final displayAccounts = accounts.take(displayLimit).toList();
    final remaining = accounts.length - displayLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.translate('accounts'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(width: 2),
                AppCircleAddButton(
                  onTap: () => _navigateToCreateAccount(context),
                ),
              ],
            ),
            InkWell(
              onTap: onViewAll,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: textMuted,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),

        // --- BODY ---
        if (accounts.isEmpty)
          AppEmptyState(
            title: 'No Accounts Yet',
            subtitle: 'Add your first account\nto start tracking money.',
            icon: Icons.account_balance_wallet_outlined,
            actionLabel: 'Add Your First Account',
            onActionTap: () => _navigateToCreateAccount(context),
            isBordered: false,
          )
        else ...[
          ...displayAccounts.map((account) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AccountItemCard(
                  account: account,
                  onTap: () => onAccountTap?.call(account),
                ),
              )),
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
