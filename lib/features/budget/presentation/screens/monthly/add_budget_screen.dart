import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/fintech_amount_input.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/button/app_button.dart';
import 'package:spend_io_app/core/utils/localization.dart';

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
              // KHỐI 1: TIÊU ĐỀ VÀ WHITE CARD NHẬP TIỀN FINTECH ĐỒNG BỘ
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
                            AppLocalizations.translate('Create Budget'),
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

                    // ✅ ĐÃ ĐỒNG BỘ: Thay thế ô nhập chữ to căn giữa bằng component White Card phẳng giống Category
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

              // KHỐI 2: ĐẨY NÚT BẤM LƯU XUỐNG ĐÁY MÀN HÌNH CHỐNG OVERFLOW CHUẨN SLIVER
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xl),
                    child: AppButton(
                      title: formVM.isSubmitting
                          ? AppLocalizations.translate('Saving...')
                          : AppLocalizations.translate('Save Budget'),
                      isLoading: formVM.isSubmitting,
                      onPressed: () async {
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

                        formVM.setAmount(cleanAmount);

                        final success = await formVM.submitBudget(
                          budgetVM: budgetVM,
                          updateBudgetUseCase: updateBudgetUseCase,
                          userId: widget.userId,
                          preferredCurrencyCode:
                              context.currencyContext.preferredCurrencyCode,
                        );

                        if (success && context.mounted) {
                          await walletVM.refreshBudgetProgress();
                          if (context.mounted) {
                            Navigator.pop(context);
                            debugPrint(
                                '[UX SUCCESS]: Cấu hình ngân sách tháng qua White Card thành công.');
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
