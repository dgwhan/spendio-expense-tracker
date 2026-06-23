import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/button/app_button.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/fintech_amount_input.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/utils/localization.dart';

class SetCategoryBudgetAmountScreen extends StatefulWidget {
  final int userId;

  const SetCategoryBudgetAmountScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SetCategoryBudgetAmountScreen> createState() {
    return _SetCategoryBudgetAmountScreenState();
  }
}

class _SetCategoryBudgetAmountScreenState
    extends State<SetCategoryBudgetAmountScreen> {
  final _amountController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formVM = context.watch<BudgetCategoryFormViewModel>();
    final budgetCategoryVM = context.read<BudgetCategoryViewModel>();
    final walletVM = context.read<WalletViewModel>();

    final targetCategory = formVM.selectedCategory;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FB),
      appBar: AppHeader(title: AppLocalizations.translate('Set Budget')),
      body: SafeArea(
        // ✅ ĐÃ SỬA: Bọc Form ở đây để cung cấpcurrentState cho _formKey.currentState!.validate() trong ViewModel không bị null
        child: Form(
          key: formVM.formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: AppSizes.md),
                    if (targetCategory != null) ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(targetCategory.colorValue)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                IconData(
                                  targetCategory.iconCodePoint,
                                  fontFamily: targetCategory.iconFontFamily ??
                                      'MaterialIcons',
                                ),
                                color: Color(targetCategory.colorValue),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                targetCategory.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(targetCategory.colorValue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.md),
                    FintechAmountInput(
                      controller: _amountController,
                      selectedType: TransactionType.expense,
                      autofocus: true,
                      currencyCode:
                          context.currencyContext.preferredCurrencyCode,
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
                    child: AppButton(
                      title: _isSaving
                          ? AppLocalizations.translate('Saving...')
                          : AppLocalizations.translate('Save Budget'),
                      isLoading: _isSaving,
                      onPressed: () async {
                        if (_isSaving) {
                          return;
                        }

                        final cleanAmount = _amountController.text
                            .replaceAll(RegExp(r'[^\d]'), '');

                        if (cleanAmount.isEmpty || cleanAmount == '0') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.translate(
                                  'Please enter a valid amount')),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isSaving = true;
                        });

                        // Cập nhật số tiền vào VM trước để hàm submitCategoryBudget có data validate
                        formVM.setAmount(cleanAmount);

                        try {
                          final success = await formVM.submitCategoryBudget(
                            categoryVM: budgetCategoryVM,
                            userId: widget.userId,
                            currencyCode:
                                context.currencyContext.preferredCurrencyCode,
                          );

                          if (success && context.mounted) {
                            await walletVM.refreshBudgetProgress();
                            if (context.mounted) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          } else {
                            if (mounted) {
                              setState(() {
                                _isSaving = false;
                              });
                            }
                          }
                        } catch (e) {
                          debugPrint(
                              '[BUDGET ERROR]: Thất bại khi lưu ngân sách danh mục: $e');
                          if (mounted) {
                            setState(() {
                              _isSaving = false;
                            });
                          }
                        }
                      },
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
