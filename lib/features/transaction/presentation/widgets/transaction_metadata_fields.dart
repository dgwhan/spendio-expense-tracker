import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';

class TransactionMetadataFields extends StatelessWidget {
  final List<AccountEntity> activeAccounts;
  final AccountEntity? selectedAccount;
  final CategoryEntity? selectedCategory;
  final DateTime selectedDate;
  final TextEditingController noteController;
  final VoidCallback onWalletTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onDateTap;

  const TransactionMetadataFields({
    super.key,
    required this.activeAccounts,
    required this.selectedAccount,
    required this.selectedCategory,
    required this.selectedDate,
    required this.noteController,
    required this.onWalletTap,
    required this.onCategoryTap,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final dividerColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF4F5F7);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Source Wallet
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: CircleAvatar(
              backgroundColor: selectedAccount == null
                  ? Colors.grey.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color:
                    selectedAccount == null ? Colors.grey : AppColors.primary,
              ),
            ),
            title: Text(
              '${AppLocalizations.translate('Source wallet')}*',
              style: AppTextStyles.caption
                  .copyWith(color: hintColor, fontSize: 11),
            ),
            subtitle: Text(
              selectedAccount?.name ??
                  AppLocalizations.translate('Select wallet'),
              style: AppTextStyles.cardTitle.copyWith(
                color: selectedAccount == null ? Colors.orange : null,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: Colors.grey),
            onTap: onWalletTap,
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),

          // 2. Category
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: CircleAvatar(
              backgroundColor: selectedCategory != null
                  ? Color(selectedCategory!.colorValue).withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
              child: Icon(
                selectedCategory != null
                    ? IconData(
                        selectedCategory!.iconCodePoint,
                        fontFamily:
                            selectedCategory!.iconFontFamily ?? 'MaterialIcons',
                      )
                    : Icons.category_outlined,
                color: selectedCategory != null
                    ? Color(selectedCategory!.colorValue)
                    : Colors.grey,
              ),
            ),
            title: Text(
              '${AppLocalizations.translate('Category')}*',
              style: AppTextStyles.caption
                  .copyWith(color: hintColor, fontSize: 11),
            ),
            subtitle: Text(
              selectedCategory?.name ??
                  AppLocalizations.translate('Select category'),
              style: AppTextStyles.cardTitle,
            ),
            trailing: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: Colors.grey),
            onTap: onCategoryTap,
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),

          // 3. Transaction Date
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child:
                  const Icon(Icons.calendar_month_rounded, color: Colors.blue),
            ),
            title: Text(
              '${AppLocalizations.translate('Transaction date')}*',
              style: AppTextStyles.caption
                  .copyWith(color: hintColor, fontSize: 11),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(selectedDate),
              style: AppTextStyles.cardTitle,
            ),
            trailing: const Icon(Icons.calendar_today_rounded,
                size: 16, color: Colors.grey),
            onTap: onDateTap,
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),

          // 4. Note Input Field
          TextFormField(
            controller: noteController,
            style:
                AppTextStyles.bodyNormal.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: AppLocalizations.translate('Add note'),
              hintStyle: AppTextStyles.bodyNormal
                  .copyWith(color: hintColor, fontSize: 13),
              prefixIcon: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 20, color: Colors.grey),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 40, minHeight: 40),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
