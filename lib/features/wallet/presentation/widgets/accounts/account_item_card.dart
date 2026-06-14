import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/edit_account_bottom_sheet.dart';
import 'package:provider/provider.dart';

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
      case AccountType.savingsAccount:
        return Icons.savings_rounded;
    }
  }

  Color _getBgColor(AccountType type, bool isDark) {
    if (isDark) {
      switch (type) {
        case AccountType.cash:
          return AppColors.cashBgDark;
        case AccountType.bank:
          return AppColors.bankBgDark;
        case AccountType.creditCard:
          return AppColors.creditCardBgDark;
        case AccountType.eWallet:
          return AppColors.eWalletBgDark;
        case AccountType.savingsAccount:
          return AppColors.savingsAccountBgDark;
      }
    } else {
      switch (type) {
        case AccountType.cash:
          return AppColors.cashBgLight;
        case AccountType.bank:
          return AppColors.bankBgLight;
        case AccountType.creditCard:
          return AppColors.creditCardBgLight;
        case AccountType.eWallet:
          return AppColors.eWalletBgLight;
        case AccountType.savingsAccount:
          return AppColors.savingsAccountBgLight;
      }
    }
  }

  Color _getIconColor(AccountType type, bool isDark) {
    if (isDark) {
      switch (type) {
        case AccountType.cash:
          return AppColors.cashDark;
        case AccountType.bank:
          return AppColors.bankDark;
        case AccountType.creditCard:
          return AppColors.creditCardDark;
        case AccountType.eWallet:
          return AppColors.eWalletDark;
        case AccountType.savingsAccount:
          return AppColors.savingsAccountDark;
      }
    } else {
      switch (type) {
        case AccountType.cash:
          return AppColors.cashLight;
        case AccountType.bank:
          return AppColors.bankLight;
        case AccountType.creditCard:
          return AppColors.creditCardLight;
        case AccountType.eWallet:
          return AppColors.eWalletLight;
        case AccountType.savingsAccount:
          return AppColors.savingsAccountLight;
      }
    }
  }

  // Khối logic hiển thị Dialog xác nhận xóa tài khoản đồng bộ 100% với AccountDetailBody
  void _showDeleteConfirmation(
      BuildContext context, WalletViewModel walletVM, AccountEntity account) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AppConfirmationDialog(
          title: 'Delete Account',
          content:
              'Are you sure you want to delete this account? This action cannot be undone.',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
          isDestructive: true,
          onConfirm: () {
            Navigator.pop(dialogCtx); // Đóng hộp thoại xác nhận
            walletVM.deleteAccount(account.id).then((_) {
              // Kích hoạt callback báo hiệu cho màn danh sách ngoài trang chủ re-load
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
    final accentColor = _getIconColor(account.type, isDark);

    final walletVM = context.read<WalletViewModel>();

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
        border: Border.all(
          color: outlineColor,
          width: 0.8,
        ),
        boxShadow: isDark
            ? const [
                BoxShadow(
                  color: AppColors.shadowNaturalDark1,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg * 1.2),
        child: Stack(
          children: [
            // Dải màu nhận diện thông minh ở góc rìa trái thẻ (Dynamic Accent Strip)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3.5,
                color: accentColor,
              ),
            ),
            // Khối nội dung tương tác Tap Ripple
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.lg * 1.2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md * 1.1,
                    vertical: AppSizes.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: AppSizes.xs),

                      // 1. Khối Hộp Icon Trái (Dual-Tone Icon Box)
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _getBgColor(account.type, isDark)
                              .withValues(alpha: isDark ? 0.2 : 0.6),
                          borderRadius:
                              BorderRadius.circular(AppRadius.md * 1.1),
                        ),
                        child: Center(
                          child: Icon(
                            _getIcon(account.type),
                            color: accentColor,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),

                      // 2. Khối Thông Tin Trung Tâm (Tên ví & Số dư bự đặt hàng dọc dọc)
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
                                letterSpacing: -0.2,
                              ),
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
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),

                      // 3. Khối Hành Động Phải (Tên tổ chức phía trên và 3 chấm tùy chọn)
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
                              color: mutedTextColor.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: AppSizes.md),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              constraints: const BoxConstraints(minWidth: 120),
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: mutedTextColor.withValues(alpha: 0.5),
                              ),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final result = await showModalBottomSheet(
                                    context: context,
                                    useRootNavigator: true,
                                    isScrollControlled: true,
                                    backgroundColor: AppColors.transparent,
                                    builder: (_) => EditAccountBottomSheet(
                                      viewModel: walletVM,
                                      account: account,
                                    ),
                                  );
                                  if (!context.mounted) return;

                                  if (result != null) {
                                    onEdit?.call();
                                  }
                                }
                                if (value == 'delete') {
                                  _showDeleteConfirmation(
                                      context, walletVM, account);
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
                                      Text(
                                        'Delete Wallet',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.error),
                                      ),
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
}
