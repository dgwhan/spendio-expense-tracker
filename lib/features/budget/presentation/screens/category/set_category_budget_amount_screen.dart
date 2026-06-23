import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class SetCategoryBudgetAmountScreen extends StatefulWidget {
  final int userId;

  const SetCategoryBudgetAmountScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SetCategoryBudgetAmountScreen> createState() =>
      _SetCategoryBudgetAmountScreenState();
}

class _SetCategoryBudgetAmountScreenState
    extends State<SetCategoryBudgetAmountScreen> {
  late final TextEditingController _amountController;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(BuildContext context, String value, BudgetCategoryFormViewModel formVM) {
    String cleanString = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanString.isEmpty || cleanString == '0') {
      _amountController.text = '';
      formVM.setAmount('0');
      setState(() => _isButtonEnabled = false);
      return;
    }

    double parsedAmount = double.parse(cleanString);
    if (parsedAmount > 999999999) {
      final double oldAmount = double.tryParse(formVM.amount) ?? 0;
      final formatter = NumberFormat.decimalPattern('vi_VN');
      final String oldFormatted = formatter.format(oldAmount.round());
      _amountController.value = TextEditingValue(
        text: oldFormatted,
        selection: TextSelection.collapsed(offset: oldFormatted.length),
      );
      return;
    }

    final formatter = NumberFormat.decimalPattern('vi_VN');
    String formatted = formatter.format(parsedAmount.round());

    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    formVM.setAmount(cleanString);
    setState(
        () => _isButtonEnabled = cleanString.isNotEmpty && cleanString != '0');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final formVM = context.watch<BudgetCategoryFormViewModel>();
    final budgetCategoryVM = context.read<BudgetCategoryViewModel>();
    final walletVM = context.read<WalletViewModel>();

    final targetCategory = formVM.selectedCategory;
    final categoryColor = targetCategory != null
        ? Color(targetCategory.colorValue)
        : AppColors.primary;

    final currencyLabel = formatCurrency(
      0,
      currencyCode: context.currencyContext.preferredCurrencyCode,
      locale: context.currencyContext.locale,
    ).replaceAll(RegExp(r'[\d\s.,]'), '');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSizes.md),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: primaryTextColor, size: 18),
            onPressed: () => Navigator.pop(context),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Text(
          'Set Balance',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: formVM.formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.md),
                if (targetCategory != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            IconData(targetCategory.iconCodePoint,
                                fontFamily: targetCategory.iconFontFamily ??
                                    'MaterialIcons'),
                            color: categoryColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            targetCategory.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(flex: 1),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: secondaryTextColor.withValues(alpha: 0.3),
                            ),
                          ),
                          validator: formVM.validateAmount,
                          onChanged: (val) => _onAmountChanged(context, val, formVM),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        currencyLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      disabledForegroundColor:
                          isDark ? Colors.grey[600] : Colors.grey[400],
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    onPressed: formVM.isSubmitting || !_isButtonEnabled
                        ? null
                        : () async {
                            debugPrint(
                                '============================================================');
                            debugPrint(
                                '[BUDGET CATEGORY SAVE ACTION]: Persisting category balance...');
                            debugPrint(
                                '[DATA LOG]: Category: ${targetCategory?.name} | Amount: ${formVM.amount}');
                            debugPrint(
                                '============================================================');

                            final success = await formVM.submitCategoryBudget(
                              categoryVM: budgetCategoryVM,
                              userId: widget.userId,
                              currencyCode: context.currencyContext.preferredCurrencyCode,
                            );

                            if (success && context.mounted) {
                              await walletVM.refreshBudgetProgress();
                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            }
                          },
                    child: formVM.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
