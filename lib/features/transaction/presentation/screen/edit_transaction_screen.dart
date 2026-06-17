import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
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
    _amountController = TextEditingController(
      text: rawAmount == rawAmount.toInt()
          ? rawAmount.toInt().toString()
          : rawAmount.toString(),
    );
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
        isSingleDateMode: true, // Kích hoạt chế độ chọn 1 ngày đơn lẻ
        maxDate: DateTime.now(), // Chặn ngày tương lai
      ),
    );

    if (pickedRange != null && mounted) {
      final selectedDay = pickedRange.start;

      final originalTime = widget.transaction.transactionDate;

      final DateTime dateWithOriginalTime = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        originalTime.hour, // Ghim đúng giờ cũ
        originalTime.minute, // Ghim đúng phút cũ
        originalTime.second, // Giữ luôn giây cũ
      );

      setState(() {
        _selectedDate = dateWithOriginalTime;
      });
    }
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a source wallet/account to continue.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final updatedTx = TransactionEntity(
      id: widget.transaction.id,
      userId: widget.transaction.userId,
      accountId: _selectedAccount!.id,
      categoryId: _selectedCategory!.id,
      amount: amount,
      type: _selectedType,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      transactionDate:
          _selectedDate, // Mang mốc ngày mới kết hợp giờ cũ an toàn
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
        // GIẬT NGƯỢC STACK 2 LẦN: Đóng màn Sửa và quay về thẳng màn hình Wallet Detail
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

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Edit Transaction',
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                centerTitle: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Expense')),
                          selected: _selectedType == TransactionType.expense,
                          selectedColor: AppColors.error.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                              color: _selectedType == TransactionType.expense
                                  ? AppColors.error
                                  : Colors.grey,
                              fontWeight: FontWeight.bold),
                          onSelected: (val) => setState(() {
                            _selectedType = TransactionType.expense;
                            _selectedCategory = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Income')),
                          selected: _selectedType == TransactionType.income,
                          selectedColor: Colors.green.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                              color: _selectedType == TransactionType.income
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: FontWeight.bold),
                          onSelected: (val) => setState(() {
                            _selectedType = TransactionType.income;
                            _selectedCategory = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FintechAmountInput(
                controller: _amountController,
                selectedType: _selectedType,
                autofocus: false,
              ),
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                sliver: SliverToBoxAdapter(
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedAccount == null
                          ? Colors.blue
                          : (_selectedType == TransactionType.expense
                              ? AppColors.error
                              : Colors.green),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.md)),
                    ),
                    child: const Text(
                      'Save Changes',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
