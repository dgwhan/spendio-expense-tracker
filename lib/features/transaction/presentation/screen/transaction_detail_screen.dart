import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/edit_transaction_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionEntity transaction;
  final List<CategoryEntity> categories;
  final TransactionViewModel transactionVM;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.categories,
    required this.transactionVM,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  // Hàm xử lý Xóa giao dịch kèm Dialog xác nhận văn minh
  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
            'Are you sure you want to permanently delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await widget.transactionVM.deleteTransaction(widget.transaction);
      if (mounted) {
        Navigator.pop(context); // Quay lại màn hình trước đó sau khi xóa xong
      }
    }
  }

  // 🌟 ĐÃ CẬP NHẬT: Luồng điều hướng sang màn hình Sửa (Edit) thông minh
  void _handleEdit() {
    debugPrint(
        'Điều hướng sang màn hình Sửa giao dịch: ${widget.transaction.id}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(
          transaction: widget.transaction,
          categories: widget.categories,
          transactionVM: widget.transactionVM,
        ),
      ),
    );
  }

  CategoryEntity? _findCategory(String categoryId) {
    try {
      return widget.categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final isExpense = widget.transaction.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.error : Colors.green;
    final amountPrefix = isExpense ? '-' : '+';

    final category = _findCategory(widget.transaction.categoryId);
    final categoryLabel = category?.name ?? widget.transaction.categoryId;

    final formatter = NumberFormat('#,###', 'vi_VN');
    final amountText =
        '$amountPrefix${formatter.format(widget.transaction.amount.abs())} đ';
    final timeDetail = DateFormat('HH:mm - dd MMMM yyyy')
        .format(widget.transaction.transactionDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _handleEdit,
            tooltip: 'Edit Transaction',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: _handleDelete,
            tooltip: 'Delete Transaction',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.md),

            // 🌟 ICON DANH MỤC TO TRÒN CHÍNH GIỮA
            _buildCategoryIconHeader(category),
            const SizedBox(height: AppSizes.sm),
            Text(categoryLabel,
                style: TextStyle(
                    fontSize: 16,
                    color: secondaryColor,
                    fontWeight: FontWeight.w500)),

            const SizedBox(height: AppSizes.md),

            // 💰 SỐ TIỀN TO BỰ CHẢN NHẢY SỐ
            Text(
              amountText,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            // 📝 KHUNG THÔNG TIN CHI TIẾT CARD
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: timeDetail,
                      primaryColor: primaryColor,
                    ),
                    const Divider(height: AppSizes.lg),
                    _buildInfoRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Wallet / Account',
                      value: widget.transaction.accountId,
                      primaryColor: primaryColor,
                    ),
                    const Divider(height: AppSizes.lg),
                    _buildInfoRow(
                      icon: Icons.notes_rounded,
                      label: 'Note',
                      value: widget.transaction.note?.isNotEmpty == true
                          ? widget.transaction.note!
                          : 'No description',
                      primaryColor: primaryColor,
                      isItalic: widget.transaction.note?.isEmpty ?? true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIconHeader(CategoryEntity? category) {
    final color = category != null ? Color(category.colorValue) : Colors.grey;
    final iconData = category != null
        ? IconData(category.iconCodePoint,
            fontFamily: category.iconFontFamily ?? 'MaterialIcons')
        : Icons.receipt_outlined;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 36),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color primaryColor,
    bool isItalic = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
