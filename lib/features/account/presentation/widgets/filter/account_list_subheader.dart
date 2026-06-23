import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/button/app_text_button.dart';

enum AccountSortOption { nameAZ, newest, oldest }

class AccountListSubheader extends StatelessWidget {
  final AccountSortOption currentSort;
  final Function(AccountSortOption) onSortSelected;

  const AccountListSubheader({
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PopupMenuButton<AccountSortOption>(
          onSelected: onSortSelected,
          constraints: const BoxConstraints(minWidth: 160),
          offset: const Offset(0, 30),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.filter_list_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              AppTextButton(
                text: _getSortLabel(currentSort),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                onTap: null,
              ),
            ],
          ),
          itemBuilder: (context) => [
            // --- TÙY CHỌN: ALPHABETICAL (A-Z) ---
            const PopupMenuItem(
              value: AccountSortOption.nameAZ,
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha_rounded, size: 16),
                  SizedBox(width: AppSizes.sm),
                  Text('Alphabetical (A-Z)', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            // --- TÙY CHỌN: NEWEST CREATED ---
            const PopupMenuItem(
              value: AccountSortOption.newest,
              child: Row(
                children: [
                  Icon(Icons.arrow_upward_rounded, size: 16),
                  SizedBox(width: AppSizes.sm),
                  Text('Newest Created', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            // --- TÙY CHỌN: OLDEST CREATED ---
            const PopupMenuItem(
              value: AccountSortOption.oldest,
              child: Row(
                children: [
                  Icon(Icons.arrow_downward_rounded, size: 16),
                  SizedBox(width: AppSizes.sm),
                  Text('Oldest Created', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
