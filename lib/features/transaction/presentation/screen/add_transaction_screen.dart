import 'dart:convert';
import 'dart:math';
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

class AddTransactionScreen extends StatefulWidget {
  final String accountId;
  final int userId;
  final TransactionViewModel transactionVM;

  const AddTransactionScreen({
    super.key,
    required this.accountId,
    required this.userId,
    required this.transactionVM,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  CategoryEntity? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  AccountEntity? _selectedAccount;

  @override
  void initState() {
    super.initState();
    final accountVM = context.read<AccountViewModel>();

    if (accountVM.accounts.isNotEmpty && widget.accountId.isNotEmpty) {
      _selectedAccount = accountVM.accounts.firstWhere(
        (acc) => acc.id == widget.accountId,
        orElse: () => accountVM.accounts.first,
      );
    } else {
      _selectedAccount = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().loadCategories(widget.userId);
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
      setState(() {
        _selectedDate = pickedRange.start;
      });
    }
  }

  Future<void> _submitData() async {
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
    //ẩn phím ảo
    FocusScope.of(context).unfocus();

    final String nativeUniqueId =
        '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999)}';

    final newTx = TransactionEntity(
      id: nativeUniqueId,
      userId: widget.userId,
      accountId: _selectedAccount!.id,
      categoryId: _selectedCategory!.id,
      amount: amount,
      type: _selectedType,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      transactionDate: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final Map<String, dynamic> txMapLog = {
      'id': newTx.id,
      'user_id': newTx.userId,
      'account_id': newTx.accountId,
      'category_id': newTx.categoryId,
      'amount': newTx.amount,
      'type': newTx.type.toString().split('.').last,
      'note': newTx.note,
      'transaction_date': newTx.transactionDate.toIso8601String(),
      'created_at': newTx.createdAt.toIso8601String(),
      'updated_at': newTx.updatedAt.toIso8601String(),
    };

    debugPrint(
        '====================================================================================================');
    debugPrint(
        '[DATABASE HANDLER] Action Triggered: onTap (Recognizer: TapGestureRecognizer)');
    debugPrint('[DATABASE HANDLER] PAYLOAD JSON STR: ${jsonEncode(txMapLog)}');
    debugPrint(
        '====================================================================================================');

    final navigator = Navigator.of(context);

    try {
      await widget.transactionVM.addTransaction(newTx);

      if (mounted) {
        navigator.pop();
        debugPrint('[UX SUCCESS]: Đã tạo giao dịch thành công.');
      }
    } catch (e) {
      debugPrint('[UX ERROR]: Thất bại khi lưu giao dịch: $e');
    }
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
                title: Text('New Transaction',
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
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
                autofocus: activeAccounts.isNotEmpty,
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
                    child: Text(
                        _selectedAccount == null
                            ? 'Continue to Create Wallet'
                            : 'Save Transaction',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
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
