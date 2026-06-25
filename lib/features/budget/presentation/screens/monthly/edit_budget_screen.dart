import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/common/app_dual_action_buttons.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/delete_budget_usecase.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/fintech_amount_input.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/core/widgets/button/app_action_button.dart';

class EditBudgetScreen extends StatefulWidget {
  final int userId;
  final BudgetEntity existingBudget;

  const EditBudgetScreen({
    super.key,
    required this.userId,
    required this.existingBudget,
  });

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final rawAmount = widget.existingBudget.amount;
    final formatter = NumberFormat.decimalPattern('vi_VN');
    _amountController =
        TextEditingController(text: formatter.format(rawAmount.round()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<BudgetFormViewModel>()
            .setupEditMode(widget.existingBudget);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _executeDelete(BudgetFormViewModel formVM,
      DeleteBudgetUseCase deleteBudgetUseCase, WalletViewModel walletVM) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Budget?'),
        content:
            const Text('Are you sure you want to remove this period limit?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await formVM.deleteBudget(
        deleteUseCase: deleteBudgetUseCase,
        userId: widget.userId,
      );

      if (!mounted) return;

      if (success) {
        await walletVM.refreshBudgetProgress();
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  void _executeSave(BudgetFormViewModel formVM, BudgetViewModel budgetVM,
      UpdateBudgetUseCase updateBudgetUseCase, WalletViewModel walletVM) async {
    final cleanAmount = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanAmount.isEmpty || cleanAmount == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.translate('Please enter a valid amount')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    formVM.setAmount(cleanAmount);

    final success = await formVM.submitBudget(
      budgetVM: budgetVM,
      updateBudgetUseCase: updateBudgetUseCase,
      userId: widget.userId,
      preferredCurrencyCode: widget.existingBudget.currencyCode,
    );

    if (!mounted) return;

    if (success) {
      await walletVM.refreshBudgetProgress();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FB);
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final formVM = context.watch<BudgetFormViewModel>();
    final budgetVM = context.read<BudgetViewModel>();
    final updateBudgetUseCase = context.read<UpdateBudgetUseCase>();
    final deleteBudgetUseCase = context.read<DeleteBudgetUseCase>();
    final walletVM = context.read<WalletViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
        title: AppLocalizations.translate('Monthly Budget'),
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Form(
          key: formVM.formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSizes.md),
                          Text(
                            AppLocalizations.translate('Update Budget'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.translate(
                                'How much do you want to spend this period?'),
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    FintechAmountInput(
                      controller: _amountController,
                      selectedType: TransactionType.expense,
                      autofocus: true,
                      currencyCode: widget.existingBudget.currencyCode,
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xl),
                    child: AppDualActionButtons(
                      primaryLabel: AppLocalizations.translate('Delete'),
                      secondaryLabel: formVM.isSubmitting
                          ? AppLocalizations.translate('Saving...')
                          : AppLocalizations.translate('Save Budget'),
                      primaryVariant: AppActionButtonVariant.delete,
                      secondaryVariant: AppActionButtonVariant.primary,
                      onPrimaryPressed: formVM.isSubmitting
                          ? null
                          : () => _executeDelete(
                              formVM, deleteBudgetUseCase, walletVM),
                      onSecondaryPressed: formVM.isSubmitting
                          ? null
                          : () => _executeSave(
                              formVM, budgetVM, updateBudgetUseCase, walletVM),
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
