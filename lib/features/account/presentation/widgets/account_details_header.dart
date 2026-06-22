import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';

class AccountDetailsHeader extends StatelessWidget {
  final String accountName;
  final double balance;
  final Color primaryTextColor;
  final VoidCallback onBackTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const AccountDetailsHeader({
    super.key,
    required this.accountName,
    required this.balance,
    required this.primaryTextColor,
    required this.onBackTap,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = balance < 0 ? AppColors.error : primaryTextColor;

    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
        onPressed: onBackTap,
      ),
      title: Text(
        accountName,
        style: AppTextStyles.headingMedium.copyWith(color: titleColor),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: primaryTextColor),
          onSelected: (value) {
            if (value == 'edit') onEditTap();
            if (value == 'delete') onDeleteTap();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 18),
                  const SizedBox(width: 10),
                  Text('Edit Account',
                      style: AppTextStyles.bodyNormal
                          .copyWith(color: primaryTextColor)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.error),
                  const SizedBox(width: 10),
                  Text('Delete Account',
                      style: AppTextStyles.bodyNormal
                          .copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
