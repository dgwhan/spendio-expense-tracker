import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
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
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/components/transaction_metadata_fields.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/shared/widgets/date_picker/app_date_picker_sheet.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

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
  String get _activeCurrencyCode =>
      _selectedAccount?.currencyCode ??
      context.currencyContext.preferredCurrencyCode;

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

    final double? amount = CurrencyFormatter.parse(_amountController.text, currencyCode: _activeCurrencyCode);

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
      currencyCode: _activeCurrencyCode,
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
    final walletVM = context.read<WalletViewModel>();

    try {
      await widget.transactionVM.addTransaction(newTx);
      await walletVM.refreshBudgetProgress();

      if (mounted) {
        navigator.pop();
        debugPrint(
            '[UX SUCCESS]: Đã tạo giao dịch và ép cập nhật tiến trình Wallet Card thành công.');
      }
    } catch (e) {
      debugPrint('[UX ERROR]: Thất bại khi lưu giao dịch: $e');
    }
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
      appBar: AppHeader(
        title: 'New Transaction',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
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

              // Ô nhập số tiền (Fintech Component)
              FintechAmountInput(
                controller: _amountController,
                selectedType: _selectedType,
                autofocus: activeAccounts.isNotEmpty,
                currencyCode: _activeCurrencyCode,
              ),

              // Các trường Metadata (Ví, Danh mục, Ngày, Ghi chú)
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

              // Nút bấm lưu giao dịch
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
                                color: AppColors.primary.withValues(alpha: 0.3),
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
                      child: Text(
                        _selectedAccount == null
                            ? 'Continue to Create Wallet'
                            : 'Save Transaction',
                        style: const TextStyle(
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
                    ? activeColor.withValues(alpha: 0.2)
                    : activeColor.withValues(alpha: 0.12))
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
