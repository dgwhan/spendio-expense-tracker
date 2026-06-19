import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/category/presentation/widgets/category_selection_sheet.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class EditCategoryBudgetScreen extends StatefulWidget {
  final int userId;

  const EditCategoryBudgetScreen({
    super.key,
    required this.userId,
  });

  @override
  State<EditCategoryBudgetScreen> createState() =>
      _EditCategoryBudgetScreenState();
}

class _EditCategoryBudgetScreenState extends State<EditCategoryBudgetScreen> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final formVM = context.read<BudgetCategoryFormViewModel>();

    final rawAmountStr = formVM.amount;
    final cleanAmountStr = rawAmountStr.replaceAll(RegExp(r'[^\d]'), '');
    final parsedAmount = double.tryParse(cleanAmountStr) ?? 0.0;

    final initialText =
        parsedAmount > 0 ? CurrencyFormatter.compact(parsedAmount) : '0';

    _amountController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value, BudgetCategoryFormViewModel formVM) {
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

  void _showCategoryPicker(BudgetCategoryFormViewModel formVM) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategorySelectionSheet(
        currentType: 'expense',
        selectedCategory: formVM.selectedCategory,
        onCategorySelected: (cat) {
          formVM.setCategory(cat);
        },
      ),
    );
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
    final buttonSecondaryColor = isDark ? Colors.grey[800] : Colors.grey[200];

    final formVM = context.watch<BudgetCategoryFormViewModel>();
    final categoryVM = context.read<BudgetCategoryViewModel>();
    final walletVM = context.read<WalletViewModel>();
    final displayName =
        formVM.selectedCategory?.name ?? 'Select Category Target';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: primaryTextColor, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Edit Limit',
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
                  'Update Limit',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Modify the configuration and spending limit for your category.',
                  style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w400),
                ),
                const Spacer(flex: 1),
                InkWell(
                  onTap: () => _showCategoryPicker(formVM),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: formVM.selectedCategory == null
                            ? Colors.orange.withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          formVM.selectedCategory != null
                              ? IconData(
                                  formVM.selectedCategory!.iconCodePoint,
                                  fontFamily:
                                      formVM.selectedCategory!.iconFontFamily ??
                                          'MaterialIcons',
                                )
                              : Icons.category_outlined,
                          color: formVM.selectedCategory != null
                              ? Color(formVM.selectedCategory!.colorValue)
                              : AppColors.primary,
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: formVM.selectedCategory != null
                                  ? primaryTextColor
                                  : secondaryTextColor,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: secondaryTextColor),
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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: buttonSecondaryColor,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          onPressed: formVM.isSubmitting
                              ? null
                              : () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md)),
                          ),
                          onPressed: formVM.isSubmitting ||
                                  formVM.selectedCategory == null
                              ? null
                              : () async {
                                  final success =
                                      await formVM.submitCategoryBudget(
                                    categoryVM: categoryVM,
                                    userId: widget.userId,
                                  );

                                  if (success && context.mounted) {
                                    await walletVM.refreshBudgetProgress();

                                    if (context.mounted) {
                                      // ✅ ĐÃ SỬA: Đẩy trạng thái true về để màn hình Detail biết cần phải reload dữ liệu
                                      Navigator.pop(context, true);
                                      debugPrint(
                                          '[UX SUCCESS]: Updated budget category config and requested wallet refresh.');
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
                                  'Save Changes',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ),
                  ],
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
