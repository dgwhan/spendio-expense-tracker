import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/button/app_button.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/filter/wallet_picker_sheet.dart';
import 'package:spend_io_app/features/category/presentation/widgets/category_selection_sheet.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/fintech_amount_input.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/transaction_metadata_fields.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/transaction_type_segment.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/shared/widgets/date_picker/app_date_picker_sheet.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

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
  State<EditTransactionScreen> createState() {
    return _EditTransactionScreenState();
  }
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _selectedType;
  CategoryEntity? _selectedCategory;
  late DateTime _selectedDate;
  AccountEntity? _selectedAccount;
  bool _isSubmitting = false;

  String get _activeCurrencyCode {
    return _selectedAccount?.currencyCode ?? widget.transaction.currencyCode;
  }

  @override
  void initState() {
    super.initState();

    final double rawAmount = widget.transaction.amount.abs();

    final String formattedInitialAmount = formatCurrency(
      rawAmount,
      currencyCode: widget.transaction.currencyCode,
      locale: context.currencyContext.locale,
    )
        .replaceAll('đ', '')
        .replaceAll('\$', '')
        .replaceAll('VND', '')
        .replaceAll('USD', '')
        .trim();

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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (_) => WalletPickerSheet(
        accounts: accounts,
        selectedAccount: _selectedAccount,
        onAccountSelected: (acc) {
          setState(() {
            _selectedAccount = acc;
          });
        },
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
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
      useSafeArea: false,
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

  Future<void> _submitData() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    final double? amount = CurrencyFormatter.parse(_amountController.text,
        currencyCode: _activeCurrencyCode);

    if (amount == null || amount <= 0 || amount > 999999999) return;

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

    setState(() {
      _isSubmitting = true;
    });

    FocusScope.of(context).unfocus();

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
      transactionDate: _selectedDate,
      createdAt: widget.transaction.createdAt,
      updatedAt: DateTime.now(),
      currencyCode: _activeCurrencyCode,
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
        '[DATABASE HANDLER] UPDATE PAYLOAD JSON STR: ${jsonEncode(txMapLog)}');
    debugPrint(
        '====================================================================================================');

    final navigator = Navigator.of(context);
    final walletVM = context.read<WalletViewModel>();

    try {
      await widget.transactionVM.updateTransaction(
        newEntity: updatedTx,
        oldEntity: widget.transaction,
      );
      await walletVM.refreshBudgetProgress();

      if (mounted) {
        int count = 0;
        navigator.popUntil((route) => count++ == 2);
      }
    } catch (e) {
      debugPrint('[UX ERROR]: Thất bại khi cập nhật giao dịch: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeAccounts = context.watch<AccountViewModel>().accounts;

    final backgroundColor =
        isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FB);
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
        title: 'Edit Transaction',
        showBack: true,
        onBack: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // THÀNH PHẦN 1: TAB SEGMENT
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.md, 12, AppSizes.md, AppSizes.sm),
                sliver: SliverToBoxAdapter(
                  child: TransactionTypeSegment(
                    selectedType: _selectedType,
                    onTypeChanged: (type) {
                      setState(() {
                        _selectedType = type;
                        _selectedCategory = null;
                      });
                    },
                  ),
                ),
              ),

              // THÀNH PHẦN 2: AMOUNT INPUT
              SliverToBoxAdapter(
                child: FintechAmountInput(
                  controller: _amountController,
                  selectedType: _selectedType,
                  autofocus: false,
                  currencyCode: _activeCurrencyCode,
                ),
              ),

              // THÀNH PHẦN 3: METADATA CARD
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.xs),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.015),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                    ),
                    child: TransactionMetadataFields(
                      activeAccounts: activeAccounts,
                      selectedAccount: _selectedAccount,
                      selectedCategory: _selectedCategory,
                      selectedDate: _selectedDate,
                      noteController: _noteController,
                      onWalletTap: () {
                        _showWalletPicker(activeAccounts);
                      },
                      onCategoryTap: _showCategoryPicker,
                      onDateTap: _pickDate,
                    ),
                  ),
                ),
              ),

              // ✅ FIX TRIỆT ĐỂ RENDERSLIVER & SNACKBAR OFF SCREEN: Ghìm chặt khối nút dưới đáy CustomScrollView chống nổ layout
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xl),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        title: 'Save Changes',
                        isLoading: _isSubmitting,
                        onPressed: _submitData,
                        variant: AppButtonVariant.primary,
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
}
