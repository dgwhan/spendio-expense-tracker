import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart'; // Import Entity thay vì Model
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart'; // Import Enum phân loại dòng tiền

class AccountDetailTransactionTile extends StatelessWidget {
  final TransactionEntity tx;

  const AccountDetailTransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final formattedAmount = CurrencyFormatter.format(tx.amount);
    final timeStr = DateFormat('HH:mm').format(tx.transactionDate);

    // Phân loại trạng thái dựa trên Enum lõi hệ thống
    final bool isExpense = tx.type == TransactionType.expense;

    // Thiết lập hệ màu sắc trực quan theo luồng Thu/Chi (Fintech Signaling Colors)
    final Color flowColor = isExpense ? AppColors.error : Colors.green;

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: AppSizes.md),
      child: Row(
        children: [
          // Khối Icon dòng tiền tinh gọn (Thay thế hệ thống category cũ)
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: flowColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: flowColor,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Khối thông tin chi tiết giao dịch phẳng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.note ??
                      (isExpense
                          ? 'Expense'
                          : 'Income'), // Hiển thị Note, nếu trống dùng nhãn dòng tiền mặc định
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr, // Đã loại bỏ hoàn toàn hiển thị chữ danh mục (tx.category)
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: mutedTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Khối hiển thị số tiền tùy biến màu sắc sống động (+ / -)
          Text(
            '${isExpense ? "-" : "+"}$formattedAmount',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isExpense
                  ? primaryTextColor
                  : Colors
                      .green, // Giữ màu chữ thường cho chi tiêu, nhấn xanh cho thu nhập
            ),
          ),
        ],
      ),
    );
  }
}
