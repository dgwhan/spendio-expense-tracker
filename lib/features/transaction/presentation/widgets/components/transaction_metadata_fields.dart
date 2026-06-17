import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
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

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            // 1. Ô chọn Ví duy nhất
            ListTile(
              contentPadding: EdgeInsets.zero,
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
              title: const Text(
                'Source Wallet',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              subtitle: Text(
                selectedAccount?.name ?? 'No Wallet Selected (Required)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: selectedAccount == null
                      ? Colors.orange
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
              trailing: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
              onTap: onWalletTap,
            ),

            // 2. Ô chọn Danh mục (Category) - Đã đồng bộ 100% với Entity & Database Seed
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: selectedCategory != null
                    ? Color(selectedCategory!.colorValue).withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
                child: Icon(
                  selectedCategory != null
                      ? IconData(
                          selectedCategory!.iconCodePoint,
                          fontFamily: selectedCategory!.iconFontFamily ??
                              'MaterialIcons',
                        )
                      : Icons.category_outlined,
                  color: selectedCategory != null
                      ? Color(selectedCategory!.colorValue)
                      : Colors.grey,
                ),
              ),
              title: Text(
                selectedCategory != null
                    ? selectedCategory!.name
                    : 'Select Category',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selectedCategory != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedCategory == null && selectedAccount == null
                      ? Colors.grey
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: onCategoryTap,
            ),

            // 3. Ô chọn Ngày tháng
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                child: const Icon(Icons.calendar_month_outlined,
                    color: Colors.blue),
              ),
              title: Text(
                DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit_calendar_outlined, size: 16),
              onTap: onDateTap,
            ),
            const SizedBox(height: AppSizes.md),

            // 4. Ô nhập Ghi chu
            TextFormField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Add note (e.g., Dinner with family)',
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.md),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}
