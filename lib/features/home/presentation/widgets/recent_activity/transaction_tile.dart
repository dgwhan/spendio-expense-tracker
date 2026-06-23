import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/features/home/data/models/recent_transaction_model.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/transaction_detail_screen.dart';

class TransactionTile extends StatelessWidget {
  final RecentTransactionModel transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  // Fallback trợ giúp phân chia kiểu cách khi không tìm thấy category thực tế
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

  // Helper định dạng ngày, giờ linh hoạt
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
    final txVM = context.read<TransactionViewModel>();
    final catVM = context.read<CategoryViewModel>();
    final accVM = context.read<AccountViewModel>();

    TransactionEntity? matchTx;
    for (final tx in txVM.state.transactions) {
      if (tx.id == transaction.id) {
        matchTx = tx;
        break;
      }
    }

    CategoryEntity? categoryEntity;
    if (matchTx != null) {
      for (final cat in catVM.state.categories) {
        if (cat.id == matchTx.categoryId) {
          categoryEntity = cat;
          break;
        }
      }
    }

    IconData iconData;
    Color iconColor;
    Color bgColor;

    if (categoryEntity != null) {
      iconData = IconData(
        categoryEntity.iconCodePoint,
        fontFamily: categoryEntity.iconFontFamily ?? 'MaterialIcons',
      );
      iconColor = Color(categoryEntity.colorValue);
      bgColor = iconColor.withValues(alpha: 0.12);
    } else {
      final style = _getCategoryStyle(transaction.category);
      iconData = style['icon'] as IconData;
      iconColor = style['color'] as Color;
      bgColor = style['bgColor'] as Color;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight;

    final displayTitle = categoryEntity?.name ?? transaction.category;

    final displaySubtitle = matchTx?.note?.isNotEmpty == true
        ? '${matchTx!.note} • ${_formatDateTime(transaction.date)}'
        : _formatDateTime(transaction.date);

    final formattedAmount = formatCurrency(
      transaction.amount.abs(),
      currencyCode: transaction.currencyCode,
      locale: context.currencyContext.locale,
    );

    return InkWell(
      onTap: () {
        if (matchTx != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(
                transaction: matchTx!,
                categories: catVM.state.categories,
                accounts: accVM.accounts,
                transactionVM: txVM,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
        child: Row(
          // ĐÃ SỬA LỖI: Thêm đầy đủ thuộc tính children để bọc mảng widget con
          children: [
            // 1. Icon danh mục tròn phẳng
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.md),

            // 2. Nội dung text (Category & Subtitle)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayTitle,
                    style: AppTextStyles.bodyNormal.copyWith(
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displaySubtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 3. Lượng tiền thu/chi
            Text(
              '${transaction.isExpense ? "-" : "+"}$formattedAmount',
              style: AppTextStyles.bodyNormal.copyWith(
                fontWeight: FontWeight.bold,
                color: transaction.isExpense
                    ? (isDark ? AppColors.error : AppColors.textPrimaryLight)
                    : AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
