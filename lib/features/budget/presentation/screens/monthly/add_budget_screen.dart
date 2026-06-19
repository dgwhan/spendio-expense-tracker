import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class AddBudgetScreen extends StatefulWidget {
  final int userId;

  const AddBudgetScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value, BudgetFormViewModel formVM) {
    String cleanString = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanString.isEmpty || cleanString == '0') {
      _amountController.text = '0';
      formVM.setAmount('0');
      return;
    }

    double parsedAmount = double.parse(cleanString);
    String formatted = CurrencyFormatter.compact(parsedAmount);

    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    formVM.setAmount(cleanString);
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

    final formVM = context.watch<BudgetFormViewModel>();
    final budgetVM = context.read<BudgetViewModel>();
    final updateBudgetUseCase = context.read<UpdateBudgetUseCase>();
    final walletVM = context.read<WalletViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: primaryTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Set Limit',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primaryTextColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: formVM.formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Limit',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'How much do you want to spend this period?',
                  style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w400),
                ),
                const Spacer(flex: 2),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor.withValues(alpha: 0.9)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          validator: formVM.validateAmount,
                          onChanged: (val) => _onAmountChanged(val, formVM),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        '₫ VND',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    onPressed: formVM.isSubmitting
                        ? null
                        : () async {
                            final success = await formVM.submitBudget(
                              budgetVM: budgetVM,
                              updateBudgetUseCase: updateBudgetUseCase,
                              userId: widget.userId,
                            );

                            if (success && context.mounted) {
                              await walletVM.refreshBudgetProgress();
                              if (context.mounted) {
                                Navigator.pop(context);
                                debugPrint(
                                    '[UX SUCCESS]: Khởi tạo hạn mức ngân sách thành công.');
                              }
                            }
                          },
                    child: formVM.isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'Save Limit',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
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
