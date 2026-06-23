import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/transaction_detail_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/account_transaction_item.dart';
import 'package:spend_io_app/core/utils/localization.dart';

class AccountTransactionFeed extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;
  final String? walletId;

  // THÊM: Nạp các biến trạng thái lọc từ Chips vào để xử lý đồng bộ
  final TransactionType? selectedType;
  final CategoryEntity? selectedCategory;
  final AccountEntity? selectedAccount;
  final String selectedDatePreset;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const AccountTransactionFeed({
    super.key,
    required this.transactions,
    required this.categories,
    this.walletId,
    this.selectedType,
    this.selectedCategory,
    this.selectedAccount,
    required this.selectedDatePreset,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  Widget build(BuildContext context) {
    // Thực hiện lọc nâng cao kết hợp tất cả điều kiện từ Chip thiết kế trơn
    final displayTransactions = transactions.where((tx) {
      // 1. Kiểm tra điều kiện ví cứng từ màn hình Detail (nếu có)
      if (walletId != null && tx.accountId != walletId) {
        return false;
      }

      // 2. Lọc theo hàng Chip 1: ALL, EXPENSE, INCOME
      if (selectedType != null && tx.type != selectedType) {
        return false;
      }

      // 3. Lọc theo hàng Chip 2: Ví / Tài khoản chọn riêng lẻ
      if (selectedAccount != null && tx.accountId != selectedAccount!.id) {
        return false;
      }

      // 4. Lọc theo hàng Chip 2: Danh mục (Category)
      if (selectedCategory != null && tx.categoryId != selectedCategory!.id) {
        return false;
      }

      // 5. Lọc theo hàng Chip 2: Thời gian chu kỳ linh hoạt
      if (selectedDatePreset != 'All') {
        final now = DateTime.now();
        final txDate = tx.transactionDate;

        if (selectedDatePreset == 'Today') {
          final today = DateTime(now.year, now.month, now.day);
          if (DateTime(txDate.year, txDate.month, txDate.day) != today) {
            return false;
          }
        } else if (selectedDatePreset == 'This Week') {
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final startOfUrl =
              DateTime(weekStart.year, weekStart.month, weekStart.day);
          if (txDate.isBefore(startOfUrl)) {
            return false;
          }
        } else if (selectedDatePreset == 'This Month') {
          if (txDate.year != now.year || txDate.month != now.month) {
            return false;
          }
        } else if (selectedDatePreset == 'Custom' &&
            customStartDate != null &&
            customEndDate != null) {
          final start = DateTime(customStartDate!.year, customStartDate!.month,
              customStartDate!.day);
          final end = DateTime(customEndDate!.year, customEndDate!.month,
              customEndDate!.day, 23, 59, 59);
          if (txDate.isBefore(start) || txDate.isAfter(end)) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    if (displayTransactions.isEmpty) {
      return _buildEmptyState();
    }

    // Nhóm giao dịch theo ngày
    final Map<String, List<TransactionEntity>> grouped = {};
    for (final tx in displayTransactions) {
      final key = _dateKey(tx.transactionDate);
      grouped.putIfAbsent(key, () {
        return [];
      }).add(tx);
    }

    // Sắp xếp ngày giảm dần (Mới nhất lên đầu)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        return b.compareTo(a);
      });
    final List<Widget> slivers = [];

    for (final key in sortedKeys) {
      final txList = grouped[key]!
        ..sort((a, b) {
          return b.transactionDate.compareTo(a.transactionDate);
        });

      slivers.add(
        SliverToBoxAdapter(
          child: _DateGroupHeader(dateKey: key),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final currentTx = txList[index];
              return AccountTransactionItem(
                tx: currentTx,
                categories: categories,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return TransactionDetailScreen(
                          transaction: currentTx,
                          categories: categories,
                          accounts: context.read<AccountViewModel>().accounts,
                          transactionVM: context.read<TransactionViewModel>(),
                        );
                      },
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
              AppLocalizations.translate('no_transactions_found'),
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
            letterSpacing: 0.8),
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
