import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/dialogs/app_dialogs.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_item_menu.dart';

class AccountItemCard extends StatelessWidget {
  final AccountEntity account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AccountItemCard({
    super.key,
    required this.account,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  IconData _getIcon(AccountType type) {
    return (switch (type) {
      AccountType.cash => Icons.payments_rounded,
      AccountType.bank => Icons.account_balance_rounded,
      AccountType.creditCard => Icons.credit_card_rounded,
      AccountType.eWallet => Icons.account_balance_wallet_rounded,
      _ => Icons.help_outline_rounded,
    });
  }

  void _showDeleteConfirmation(BuildContext context, AccountViewModel accountVM,
      AccountEntity account) async {
    final confirm = await AppDialogs.showDelete(
      context: context,
      title: 'Delete Account',
      content:
          'Are you sure you want to delete this account? This action cannot be undone.',
    );

    if (confirm == true && context.mounted) {
      final localId = account.userId;
      final String remoteUid = FirebaseAuth.instance.currentUser?.uid ?? '';

      await accountVM.deleteAccount(localId, remoteUid, account.id);

      if (context.mounted) {
        // Tách biệt microtask gọi làm mới data feed giao diện tránh xung đột luồng vẽ màn hình danh sách
        Future.microtask(() => onDelete?.call());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceSecondaryDark : Colors.white;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final isNegative = account.balance < 0;
    final balanceColor = isNegative ? AppColors.error : primaryTextColor;

    final accountVM = Navigator.of(context).mounted
        ? (tryWatch(context) ?? context.read<AccountViewModel>())
        : context.read<AccountViewModel>();

    final institutionText = (switch (account.type) {
      AccountType.bank => 'Atm',
      AccountType.creditCard => 'Credit',
      AccountType.cash => 'Cash',
      _ => account.type.displayName,
    })
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg * 1.2),
        boxShadow: isDark
            ? const [
                BoxShadow(
                    color: AppColors.shadowNaturalDark1,
                    blurRadius: 16,
                    offset: Offset(0, 6))
              ]
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 14,
                    offset: const Offset(0, 4)),
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 28,
                    offset: const Offset(0, 8)),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg * 1.2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg * 1.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md * 1.1, vertical: AppSizes.md),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: account.type.bgColor,
                      borderRadius: BorderRadius.circular(AppRadius.md * 1.1),
                    ),
                    child: Center(
                      child: Icon(_getIcon(account.type),
                          color: account.type.mainColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyNormal.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                              letterSpacing: -0.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(account.balance),
                          style: AppTextStyles.largeAmount.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: balanceColor,
                              letterSpacing: -0.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        institutionText,
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: mutedTextColor.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AccountItemMenu(
                        account: account,
                        accountVM: accountVM,
                        mutedTextColor: mutedTextColor,
                        onEdit: onEdit,
                        onDeleteTap: () => _showDeleteConfirmation(
                            context, accountVM, account),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AccountViewModel? tryWatch(BuildContext context) {
    try {
      return context.watch<AccountViewModel>();
    } catch (_) {
      return null;
    }
  }
}
