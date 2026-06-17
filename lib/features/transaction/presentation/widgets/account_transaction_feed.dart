import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // 🔥 Đã thêm để dùng context.read lấy ViewModel
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/transaction_detail_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/components/account_transaction_item.dart';

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

    // Thực hiện lọc theo ví nếu đang ở màn hình Detail ví
    final displayTransactions = walletId != null
        ? transactions.where((tx) => tx.accountId == walletId).toList()
        : transactions;

    if (displayTransactions.isEmpty) {
      return _buildEmptyState();
    }

    // Nhóm giao dịch theo ngày
    final Map<String, List<TransactionEntity>> grouped = {};
    for (final tx in displayTransactions) {
      final key = _dateKey(tx.transactionDate);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    // Sắp xếp ngày giảm dần (Mới nhất lên đầu)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final List<Widget> slivers = [];

    for (final key in sortedKeys) {
      final txList = grouped[key]!
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      // Header ngày (TODAY, YESTERDAY, ...)
      slivers.add(
        SliverToBoxAdapter(
          child: _DateGroupHeader(dateKey: key),
        ),
      );

      // Danh sách các Item giao dịch trong ngày
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final currentTx = txList[index]; // Bốc item hiện tại ra

              return AccountTransactionItem(
                tx: currentTx,
                categories: categories,
                onTap: () {
                  debugPrint('Bấm vào giao dịch: ${currentTx.id}');

                  // 🌟 LUỒNG CHUYỂN MÀN CHI TIẾT THẦN THÁNH Ở ĐÂY NÈ MÁ!
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailScreen(
                        transaction: currentTx,
                        categories: categories,
                        transactionVM: context.read<
                            TransactionViewModel>(), // Truyền VM sang để xóa/sửa
                      ),
                    ),
                  );
                },
              );
            },
            childCount: txList.length,
          ),
        ),
      );
    }

    return MultiSliver(children: slivers);
  }

  Widget _buildEmptyState() {
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

class MultiSliver extends StatelessWidget {
  final List<Widget> children;
  const MultiSliver({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: children);
  }
}
