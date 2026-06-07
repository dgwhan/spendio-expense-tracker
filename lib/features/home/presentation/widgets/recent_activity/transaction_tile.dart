import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/datasource/models/recent_transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final RecentTransactionModel transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  //helper màu phân chia category
  Map<String, dynamic> _getCategoryStyle(String category) {
    switch (category) {
      case 'Food & Drink':
        return {
          'icon': Icons.local_dining_outlined,
          'color': Colors.orange.shade800,
          'bgColor': Colors.orange.shade50,
        };
      case 'Transport':
        return {
          'icon': Icons.directions_bike_outlined,
          'color': Colors.green.shade800,
          'bgColor': Colors.green.shade50,
        };
      case 'Groceries':
        return {
          'icon': Icons.shopping_basket_outlined,
          'color': Colors.blue.shade800,
          'bgColor': Colors.blue.shade50,
        };
      default:
        return {
          'icon': Icons.receipt_long_outlined,
          'color': Colors.grey.shade800,
          'bgColor': Colors.grey.shade100,
        };
    }
  }

  //helper định dạng ngày, giờ
  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getCategoryStyle(transaction.category);
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final formattedAmount =
        formatter.format(transaction.amount).replaceAll(' ', '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          //icon danh mục
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: style['bgColor'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              style['icon'],
              color: style['color'],
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          //tiêu đề giao dịch và thời gian
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.category} • ${_formatDateTime(transaction.date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),

          Text(
            '${transaction.isExpense ? "-" : "+"}$formattedAmount',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: transaction.isExpense
                      ? AppColors.textPrimaryLight
                      : Colors.green.shade700,
                ),
          ),
        ],
      ),
    );
  }
}
