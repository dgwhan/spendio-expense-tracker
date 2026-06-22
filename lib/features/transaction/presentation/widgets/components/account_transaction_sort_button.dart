import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/presentation/widgets/filter/account_list_subheader.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';

class AccountTransactionSortButton extends StatelessWidget {
  final AccountSortOption currentSort;
  final Function(AccountSortOption) onSortSelected;

  const AccountTransactionSortButton({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  String _getSortLabel(AccountSortOption option) {
    return (switch (option) {
      AccountSortOption.nameAZ => 'A - Z',
      AccountSortOption.newest => 'Newest',
      AccountSortOption.oldest => 'Oldest',
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AccountSortOption>(
      onSelected: onSortSelected,
      constraints: const BoxConstraints(minWidth: 160),
      offset: const Offset(0, 40),
      // Thay đổi ở đây: Bọc Row để hiển thị cả Icon lọc và chữ kết hợp InkWell của AppTextButton
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list_rounded, // Icon lọc phong cách Fintech phẳng
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          AppTextButton(
            text: _getSortLabel(currentSort),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            onTap: null, // Giao quyền Handler chạm cho PopupMenuButton
          ),
        ],
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: AccountSortOption.newest,
          child: Row(
            children: [
              Icon(Icons.arrow_upward_rounded, size: 16),
              SizedBox(width: AppSizes.sm),
              Text('Newest Transactions', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: AccountSortOption.oldest,
          child: Row(
            children: [
              Icon(Icons.arrow_downward_rounded, size: 16),
              SizedBox(width: AppSizes.sm),
              Text('Oldest Transactions', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
