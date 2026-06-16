import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:spend_io_app/features/account/presentation/widgets/edit_account_bottom_sheet.dart';

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
    switch (type) {
      case AccountType.cash:
        return Icons.payments_rounded;
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.creditCard:
        return Icons.credit_card_rounded;
      case AccountType.eWallet:
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, AccountViewModel accountVM, AccountEntity account) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogCtx) {
        return AppConfirmationDialog(
          title: 'Delete Account',
          content:
              'Are you sure you want to delete this account? This action cannot be undone.',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
          isDestructive: true,
          onConfirm: () {
            final localId = account.userId;

            final currentUser = FirebaseAuth.instance.currentUser;
            final String remoteUid = currentUser?.uid ?? '';
            final String userEmail = currentUser?.email ?? '';

            accountVM
                .deleteAccount(
              localId,
              remoteUid,
              account.id,
              onboardingRepo: context.read<OnboardingRepository>(),
              userEmail: userEmail,
            )
                .then((_) {
              onDelete?.call();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceSecondaryDark : Colors.white;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final outlineColor =
        isDark ? AppColors.outlineDark : const Color(0xFFF1F1F1);

    final accentColor = account.type.mainColor;
    final iconBgColor = account.type.bgColor;

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
        border: Border.all(color: outlineColor, width: 0.8),
        boxShadow: isDark
            ? const [
                BoxShadow(
                    color: AppColors.shadowNaturalDark1,
                    blurRadius: 16,
                    offset: Offset(0, 6))
              ]
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 4)),
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 28,
                    offset: const Offset(0, 8)),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg * 1.2),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 3.5, color: accentColor),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.lg * 1.2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md * 1.1, vertical: AppSizes.md),
                  child: Row(
                    children: [
                      const SizedBox(width: AppSizes.xs),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md * 1.1),
                        ),
                        child: Center(
                          child: Icon(_getIcon(account.type),
                              color: accentColor, size: 22),
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
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                  letterSpacing: -0.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(account.balance),
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: primaryTextColor,
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
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: mutedTextColor.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: AppSizes.md),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              constraints: const BoxConstraints(minWidth: 120),
                              icon: Icon(Icons.more_vert_rounded,
                                  color: mutedTextColor.withValues(alpha: 0.5)),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final result = await showModalBottomSheet(
                                    context: context,
                                    useRootNavigator: false,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => EditAccountBottomSheet(
                                        viewModel: accountVM, account: account),
                                  );
                                  if (!context.mounted) return;
                                  if (result != null) onEdit?.call();
                                }
                                if (value == 'delete') {
                                  _showDeleteConfirmation(
                                      context, accountVM, account);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 16),
                                      SizedBox(width: AppSizes.sm),
                                      Text('Edit Wallet',
                                          style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded,
                                          size: 16, color: AppColors.error),
                                      SizedBox(width: AppSizes.sm),
                                      Text('Delete Wallet',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
