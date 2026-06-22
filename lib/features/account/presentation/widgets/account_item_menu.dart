import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/screen/edit_account_screen.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';

class AccountItemMenu extends StatelessWidget {
  final AccountEntity account;
  final AccountViewModel accountVM;
  final VoidCallback? onEdit;
  final VoidCallback onDeleteTap;
  final Color mutedTextColor;

  const AccountItemMenu({
    super.key,
    required this.account,
    required this.accountVM,
    required this.mutedTextColor,
    required this.onDeleteTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            // Chuyển đổi luồng từ bottom sheet sang mở màn hình độc lập (Screen)
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditAccountScreen(viewModel: accountVM, account: account),
              ),
            );
            if (!context.mounted) return;
            if (result == true) onEdit?.call();
          } else if (value == 'delete') {
            onDeleteTap();
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 16),
                SizedBox(width: AppSizes.sm),
                Text('Edit Wallet', style: TextStyle(fontSize: 13)),
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
                    style: TextStyle(fontSize: 13, color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
