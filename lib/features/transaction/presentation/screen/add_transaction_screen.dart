import 'dart:math';
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
  State<AddTransactionScreen> createState() {
    return _AddTransactionScreenState();
  }
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  CategoryEntity? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  AccountEntity? _selectedAccount;
  bool _isSubmitting = false;

  String get _activeCurrencyCode {
    return _selectedAccount?.currencyCode ??
        context.currencyContext.preferredCurrencyCode;
  }

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
      setState(() {
        _selectedDate = pickedRange.start;
      });
    }
  }

  Future<void> _submitData() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    final double? amount = CurrencyFormatter.parse(_amountController.text,
        currencyCode: _activeCurrencyCode);

    if (amount == null || amount <= 0 || amount > 999999999) {
      return;
    }

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a source wallet to continue.'),
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

    final navigator = Navigator.of(context);
    final walletVM = context.read<WalletViewModel>();

    try {
      await widget.transactionVM.addTransaction(newTx);
      await walletVM.refreshBudgetProgress();

      if (mounted) {
        if (Navigator.canPop(context)) {
          navigator.pop();
        }
      }
    } catch (e) {
      debugPrint('[UX ERROR]: Thất bại khi lưu giao dịch: $e');
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
        title: 'New Transaction',
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
              SliverToBoxAdapter(
                child: FintechAmountInput(
                  controller: _amountController,
                  selectedType: _selectedType,
                  autofocus: activeAccounts.isNotEmpty,
                  currencyCode: _activeCurrencyCode,
                ),
              ),
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
                        title: _selectedAccount == null
                            ? 'Continue to Create Wallet'
                            : 'Save Transaction',
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
