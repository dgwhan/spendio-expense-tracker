import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

class AccountTransactionItem extends StatelessWidget {
  final TransactionEntity tx;
  final List<CategoryEntity> categories;
  final VoidCallback? onTap; // Thêm callback để sau này bấm vào xem/sửa/xóa

  const AccountTransactionItem({
    super.key,
    required this.tx,
    required this.categories,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final isExpense = tx.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.error : Colors.green;
    final amountPrefix = isExpense ? '-' : '+';

    final category = _findCategory(tx.categoryId);
    final timeLabel = DateFormat('HH:mm').format(tx.transactionDate);
    final categoryLabel = category?.name ?? tx.categoryId;

    final formatter = NumberFormat('#,###', 'vi_VN');
    final amountText = '$amountPrefix${formatter.format(tx.amount.abs())} đ';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: Row(
          children: [
            _CategoryIcon(category: category),
            const SizedBox(width: AppSizes.sm),

            // Phần hiển thị Note + Meta (Thời gian & Danh mục)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.note?.isNotEmpty == true ? tx.note! : categoryLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$timeLabel • $categoryLabel',
                    style: TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                ],
              ),
            ),

            // Số tiền giao dịch
            Text(
              amountText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  CategoryEntity? _findCategory(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }
}

class _CategoryIcon extends StatelessWidget {
  final CategoryEntity? category;

  const _CategoryIcon({this.category});

  @override
  Widget build(BuildContext context) {
    if (category != null) {
      final color = Color(category!.colorValue);
      final iconData = IconData(
        category!.iconCodePoint,
        fontFamily: category!.iconFontFamily ?? 'MaterialIcons',
      );

      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(iconData, color: color, size: 20),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.receipt_outlined, color: Colors.grey, size: 20),
    );
  }
}
