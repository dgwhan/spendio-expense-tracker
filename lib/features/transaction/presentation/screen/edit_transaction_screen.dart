import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/app_header.dart'; // Đồng bộ sử dụng AppHeader
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';

import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/wallet_picker_sheet.dart';
import 'package:spend_io_app/features/category/presentation/widgets/category_selection_sheet.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';

import 'package:spend_io_app/features/transaction/presentation/widgets/components/fintech_amount_input.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/components/transaction_metadata_fields.dart';
import 'package:spend_io_app/shared/widgets/date_picker/app_date_picker_sheet.dart';

// Import core formatter để hiển thị số tiền ban đầu có dấu chấm phân cách chuẩn xác
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionEntity transaction;
  final List<CategoryEntity> categories;
  final TransactionViewModel transactionVM;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.categories,
    required this.transactionVM,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _selectedType;
  CategoryEntity? _selectedCategory;
  late DateTime _selectedDate;
  AccountEntity? _selectedAccount;

  @override
  void initState() {
    super.initState();

    final double rawAmount = widget.transaction.amount.abs();

    // ĐỔI MỚI: Dùng formatCurrency từ core và loại bỏ chữ 'đ' để hiển thị số tiền cũ dạng "1.000" thay vì số thô "1000"
    final String formattedInitialAmount =
        formatCurrency(rawAmount).replaceAll('đ', '').trim();

    _amountController = TextEditingController(text: formattedInitialAmount);
    _noteController =
        TextEditingController(text: widget.transaction.note ?? '');

    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.transactionDate;

    final accountVM = context.read<AccountViewModel>();
    if (accountVM.accounts.isNotEmpty) {
      _selectedAccount = accountVM.accounts.firstWhere(
        (acc) => acc.id == widget.transaction.accountId,
        orElse: () => accountVM.accounts.first,
      );
    }

    try {
      _selectedCategory = widget.categories.firstWhere(
        (cat) => cat.id == widget.transaction.categoryId,
      );
    } catch (_) {
      _selectedCategory = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CategoryViewModel>()
          .loadCategories(widget.transaction.userId);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showWalletPicker(List<AccountEntity> accounts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => WalletPickerSheet(
        accounts: accounts,
        selectedAccount: _selectedAccount,
        onAccountSelected: (acc) => setState(() => _selectedAccount = acc),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategorySelectionSheet(
        currentType:
            _selectedType == TransactionType.expense ? 'expense' : 'income',
        selectedCategory: _selectedCategory,
        onCategorySelected: (cat) {
          setState(() {
            _selectedCategory = cat;
          });
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTimeRange? pickedRange =
        await showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppDatePickerSheet(
        initialRange: DateTimeRange(start: _selectedDate, end: _selectedDate),
        isSingleDateMode: true,
        maxDate: DateTime.now(),
      ),
    );

    if (pickedRange != null && mounted) {
      final selectedDay = pickedRange.start;
      final originalTime = widget.transaction.transactionDate;

      final DateTime dateWithOriginalTime = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        originalTime.hour,
        originalTime.minute,
        originalTime.second,
      );

      setState(() {
        _selectedDate = dateWithOriginalTime;
      });
    }
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    // ĐỔI MỚI: Loại bỏ dấu chấm để parse ngược về int đẩy xuống Database lưu trữ chính xác
    final String cleanAmountStr = _amountController.text.replaceAll('.', '');
    final int? amount = int.tryParse(cleanAmountStr);

    if (amount == null || amount <= 0) return;

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a source wallet/account to continue.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final updatedTx = TransactionEntity(
      id: widget.transaction.id,
      userId: widget.transaction.userId,
      accountId: _selectedAccount!.id,
      categoryId: _selectedCategory!.id,
      amount: amount
          .toDouble(), // Ép kiểu về double nếu trường entity hiện tại yêu cầu double
      type: _selectedType,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      transactionDate: _selectedDate,
      createdAt: widget.transaction.createdAt,
      updatedAt: DateTime.now(),
    );

    final Map<String, dynamic> txMapLog = {
      'id': updatedTx.id,
      'user_id': updatedTx.userId,
      'account_id': updatedTx.accountId,
      'category_id': updatedTx.categoryId,
      'amount': updatedTx.amount,
      'type': updatedTx.type.toString().split('.').last,
      'note': updatedTx.note,
      'transaction_date': updatedTx.transactionDate.toIso8601String(),
      'created_at': updatedTx.createdAt.toIso8601String(),
      'updated_at': updatedTx.updatedAt.toIso8601String(),
    };

    debugPrint(
        '====================================================================================================');
    debugPrint(
        '[DATABASE HANDLER] Action Triggered: onTap (Update Transaction)');
    debugPrint(
        '[DATABASE HANDLER] UPDATE PAYLOAD JSON STR: ${jsonEncode(txMapLog)}');
    debugPrint(
        '====================================================================================================');

    widget.transactionVM
        .updateTransaction(
      newEntity: updatedTx,
      oldEntity: widget.transaction,
    )
        .then((_) {
      if (mounted) {
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeAccounts = context.watch<AccountViewModel>().accounts;

    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor = isDark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      // ĐỒNG BỘ: Sử dụng AppHeader hệ thống thống nhất thay cho SliverAppBar rời rạc
      appBar: AppHeader(
        title: 'Edit Transaction',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ĐỒNG BỘ: Custom Segmented Tab chuyển đổi trạng thái Expense / Income
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.md),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildTypeSegment(
                          label: 'Expense',
                          isSelected: _selectedType == TransactionType.expense,
                          activeColor: AppColors.expense,
                          isDark: isDark,
                          onTap: () => setState(() {
                            _selectedType = TransactionType.expense;
                            _selectedCategory = null;
                          }),
                        ),
                        _buildTypeSegment(
                          label: 'Income',
                          isSelected: _selectedType == TransactionType.income,
                          activeColor: AppColors.income,
                          isDark: isDark,
                          onTap: () => setState(() {
                            _selectedType = TransactionType.income;
                            _selectedCategory = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ĐỒNG BỘ: Ô nhập tiền Fintech không border, tự động thêm dấu chấm hàng nghìn
              FintechAmountInput(
                controller: _amountController,
                selectedType: _selectedType,
                autofocus: false,
              ),

              // ĐỒNG BỘ: Grouped Card chứa Metadata Fields (Ví, Danh mục, Ngày, Note)
              TransactionMetadataFields(
                activeAccounts: activeAccounts,
                selectedAccount: _selectedAccount,
                selectedCategory: _selectedCategory,
                selectedDate: _selectedDate,
                noteController: _noteController,
                onWalletTap: () => _showWalletPicker(activeAccounts),
                onCategoryTap: _showCategoryPicker,
                onDateTap: _pickDate,
              ),

              // ĐỒNG BỘ: Nút bấm Submit phủ Gradient thương hiệu chuyển động mượt mà
              SliverPadding(
                padding: const EdgeInsets.all(AppSizes.md),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _selectedAccount == null
                          ? null
                          : const LinearGradient(
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      color:
                          _selectedAccount == null ? AppColors.disabled : null,
                      boxShadow: _selectedAccount == null
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget nội bộ tạo khối lựa chọn chuyển trạng thái mượt mà
  Widget _buildTypeSegment({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? activeColor.withOpacity(0.2)
                    : activeColor.withOpacity(0.12))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? activeColor
                    : (isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
