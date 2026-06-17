import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

class AccountTransactionFeed extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;
  final String? walletId;

  const AccountTransactionFeed({
    super.key,
    required this.transactions,
    required this.categories,
    this.walletId,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '[TransactionFeed UI] Tổng số giao dịch gốc nhận từ Provider: ${transactions.length}');
    if (walletId != null) {
      debugPrint(
          '[TransactionFeed UI] Đang mở màn hình Detail - Kích hoạt bộ lọc theo Wallet ID: $walletId');
    }

    // Thực hiện lọc theo ví nếu đang ở màn hình Detail
    final displayTransactions = walletId != null
        ? transactions.where((tx) => tx.accountId == walletId).toList()
        : transactions;

    debugPrint(
        '[TransactionFeed UI] Số lượng giao dịch đủ điều kiện hiển thị lên màn hình: ${displayTransactions.length}');

    if (displayTransactions.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'No transactions found',
                style: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group transactions by date
    final Map<String, List<TransactionEntity>> grouped = {};
    for (final tx in displayTransactions) {
      final key = _dateKey(tx.transactionDate);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    // Sort groups descending
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final List<Widget> slivers = [];

    for (final key in sortedKeys) {
      final txList = grouped[key]!
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      slivers.add(
        SliverToBoxAdapter(
          child: _DateGroupHeader(dateKey: key),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _TransactionItem(tx: txList[index], categories: categories),
            childCount: txList.length,
          ),
        ),
      );
    }

    return MultiSliver(children: slivers);
  }

  String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

class _DateGroupHeader extends StatelessWidget {
  final String dateKey;

  const _DateGroupHeader({required this.dateKey});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    String label;
    if (target == today) {
      label = 'TODAY - ${DateFormat('MMMM d').format(date).toUpperCase()}';
    } else if (target == yesterday) {
      label = 'YESTERDAY - ${DateFormat('MMMM d').format(date).toUpperCase()}';
    } else {
      label = DateFormat('MMMM d').format(date).toUpperCase();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionEntity tx;
  final List<CategoryEntity> categories;

  const _TransactionItem({
    required this.tx,
    required this.categories,
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

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.xs),
      child: Row(
        children: [
          _CategoryIcon(category: category),
          const SizedBox(width: AppSizes.sm),

          // Title + meta
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

          // Amount
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

class MultiSliver extends StatelessWidget {
  final List<Widget> children;

  const MultiSliver({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: children);
  }
}
