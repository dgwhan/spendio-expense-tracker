import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/widgets/common/app_dual_action_buttons.dart'; // core action buttons dùng chung
import 'package:spend_io_app/core/widgets/button/app_action_button.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/edit_transaction_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/transaction_info_card.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionEntity transaction;
  final List<CategoryEntity> categories;
  final List<AccountEntity> accounts;
  final TransactionViewModel transactionVM;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.categories,
    required this.accounts,
    required this.transactionVM,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  // handle delete
  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Transaction', style: AppTextStyles.headingMedium),
        content: Text(
          'Are you sure you want to permanently delete this transaction? This action cannot be undone.',
          style: AppTextStyles.bodyNormal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: AppTextStyles.buttonLabel.copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style:
                    AppTextStyles.buttonLabel.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await widget.transactionVM.deleteTransaction(widget.transaction);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // handle edit
  void _handleEdit() {
    debugPrint('Navigation triggered: Edit transaction');
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

  // find category
  CategoryEntity? _findCategory(String categoryId) {
    try {
      return widget.categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  // find account
  AccountEntity? _findAccount(String accountId) {
    try {
      return widget.accounts.firstWhere((a) => a.id == accountId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceLight;

    final isExpense = widget.transaction.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.error : AppColors.success;
    final amountPrefix = isExpense ? '-' : '+';

    final category = _findCategory(widget.transaction.categoryId);
    final categoryLabel = category?.name ?? widget.transaction.categoryId;

    final account = _findAccount(widget.transaction.accountId);
    final accountLabel = account?.name ?? 'Unknown Wallet';

    final amountText = '$amountPrefix${formatCurrency(
      widget.transaction.amount.abs(),
      currencyCode: widget.transaction.currencyCode,
      locale: context.currencyContext.locale,
    )}';
    final timeDetail = DateFormat('HH:mm - dd MMMM yyyy')
        .format(widget.transaction.transactionDate);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
        title: 'Transaction Details',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // category icon
              _buildCategoryIconHeader(category),
              const SizedBox(height: AppSizes.sm),
              Text(
                categoryLabel,
                style:
                    AppTextStyles.cardTitle.copyWith(color: secondaryTextColor),
              ),
              const SizedBox(height: AppSizes.sm),

              // amount display
              Text(
                amountText,
                style: AppTextStyles.largeAmount.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),

              // transaction info card
              TransactionInfoCard(
                timeDetail: timeDetail,
                accountLabel: accountLabel,
                note: widget.transaction.note,
                surfaceColor: surfaceColor,
                primaryTextColor: primaryTextColor,
                mutedTextColor: mutedTextColor,
              ),
              const SizedBox(height: AppSizes.lg),

              AppDualActionButtons(
                primaryLabel: 'Edit',
                secondaryLabel: 'Delete',
                onPrimaryPressed: _handleEdit,
                onSecondaryPressed: _handleDelete,
                secondaryVariant: AppActionButtonVariant.delete,
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  // category icon header builder
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
      child: Icon(iconData, color: color, size: 34),
    );
  }
}
