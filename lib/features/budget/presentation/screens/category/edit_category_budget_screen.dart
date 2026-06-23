import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/button/app_button.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/category/presentation/widgets/category_selection_sheet.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/fintech_amount_input.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class EditCategoryBudgetScreen extends StatefulWidget {
  final int userId;
  final double? initialAmount;

  const EditCategoryBudgetScreen({
    super.key,
    required this.userId,
    this.initialAmount,
  });

  @override
  State<EditCategoryBudgetScreen> createState() {
    return _EditCategoryBudgetScreenState();
  }
}

class _EditCategoryBudgetScreenState extends State<EditCategoryBudgetScreen> {
  late final TextEditingController _amountController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final double rawAmount = widget.initialAmount ?? 0.0;

    String initialText = '0';
    if (rawAmount > 0) {
      initialText = formatCurrency(
        rawAmount,
        currencyCode: context.read<CurrencyContext>().preferredCurrencyCode,
        locale: context.read<CurrencyContext>().locale,
      )
          .replaceAll('đ', '')
          .replaceAll('\$', '')
          .replaceAll('VND', '')
          .replaceAll('USD', '')
          .trim();
    }

    _amountController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showCategoryPicker(BudgetCategoryFormViewModel formVM) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (_) {
        return CategorySelectionSheet(
          currentType: 'expense',
          selectedCategory: formVM.selectedCategory,
          onCategorySelected: (cat) {
            formVM.setCategory(cat);
          },
        );
      },
    );
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
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    final formVM = context.watch<BudgetCategoryFormViewModel>();
    final categoryVM = context.read<BudgetCategoryViewModel>();
    final walletVM = context.read<WalletViewModel>();

    final displayName = formVM.selectedCategory?.name ??
        AppLocalizations.translate('Select Category Target');
    final activeCurrencyCode = formVM.isEditMode
        ? formVM.editingCategoryBudget?.currencyCode ??
            context.currencyContext.preferredCurrencyCode
        : context.currencyContext.preferredCurrencyCode;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
        title: AppLocalizations.translate('Edit Budget'),
        showBack: true,
        onBack: () {
          Navigator.pop(context, false);
        },
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
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.xs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                'Modify the configuration and spending limit for your category.'),
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
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: InkWell(
                        onTap: () => _showCategoryPicker(formVM),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.015),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: formVM.selectedCategory != null
                                    ? Color(formVM.selectedCategory!.colorValue)
                                        .withValues(alpha: 0.12)
                                    : AppColors.primary.withValues(alpha: 0.12),
                                child: Icon(
                                  formVM.selectedCategory != null
                                      ? IconData(
                                          formVM
                                              .selectedCategory!.iconCodePoint,
                                          fontFamily: formVM.selectedCategory!
                                                  .iconFontFamily ??
                                              'MaterialIcons',
                                        )
                                      : Icons.category_outlined,
                                  color: formVM.selectedCategory != null
                                      ? Color(
                                          formVM.selectedCategory!.colorValue)
                                      : AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: AppSizes.md),
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: formVM.selectedCategory != null
                                        ? primaryTextColor
                                        : secondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded,
                                  color: secondaryTextColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    FintechAmountInput(
                      controller: _amountController,
                      selectedType: TransactionType.expense,
                      autofocus: true,
                      currencyCode: activeCurrencyCode,
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
                          : AppLocalizations.translate('Save Changes'),
                      isLoading: _isSaving,
                      onPressed: formVM.selectedCategory == null
                          ? null
                          : () async {
                              if (_isSaving) return;

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

                              formVM.setAmount(cleanAmount);

                              try {
                                final success =
                                    await formVM.submitCategoryBudget(
                                  categoryVM: categoryVM,
                                  userId: widget.userId,
                                  currencyCode: activeCurrencyCode,
                                );

                                if (success && context.mounted) {
                                  await walletVM.refreshBudgetProgress();
                                  if (context.mounted) {
                                    Navigator.pop(context, true);
                                  }
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      _isSaving = false;
                                    });
                                  }
                                }
                              } catch (e) {
                                debugPrint('[BUDGET UPDATE ERROR]: $e');
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
