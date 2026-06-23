import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/common/app_dual_action_buttons.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_type_grid_selector.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/currency_input_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class AccountForm extends StatefulWidget {
  final AccountEntity? account;
  final String title;
  final String actionLabel;
  final Future<void> Function(String name, AccountType type, double balance, String currencyCode) onSubmit;

  const AccountForm({
    super.key,
    this.account,
    required this.title,
    required this.actionLabel,
    required this.onSubmit,
  });

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AccountType _selectedType;
  late String _selectedCurrency;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _selectedType = widget.account?.type ?? AccountType.cash;
    _selectedCurrency = widget.account?.currencyCode ?? 'USD';

    // Wait for frame to resolve context if widget.account is null, otherwise format right away
    if (widget.account != null) {
      final formatter = NumberFormat.decimalPattern('vi_VN');
      final String initialFormatted = formatter.format(widget.account!.balance.round());
      _balanceController = TextEditingController(text: initialFormatted);
    } else {
      _balanceController = TextEditingController(text: '');
    }

    if (widget.account == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedCurrency = context.currencyContext.preferredCurrencyCode;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final inputFillColor = isDark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondaryLight;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: AppTextStyles.headingMedium
                  .copyWith(color: primaryTextColor, fontSize: 20),
            ),
            const SizedBox(height: AppSizes.lg),

            // Name Field
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.bodyNormal.copyWith(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. My Savings, Daily Cash',
                labelStyle:
                    AppTextStyles.caption.copyWith(color: mutedTextColor),
                hintStyle: AppTextStyles.bodyNormal
                    .copyWith(color: mutedTextColor.withValues(alpha: 0.6)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                filled: true,
                fillColor: inputFillColor,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Account name is required';
                }
                if (value.trim().length < 2) {
                  return 'Account name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),

            // Balance Field với bộ gõ phân tách hàng nghìn động
            TextFormField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyNormal.copyWith(color: primaryTextColor),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(currencyCode: _selectedCurrency),
              ],
              decoration: InputDecoration(
                labelText: 'Balance',
                hintText: '0',
                labelStyle:
                    AppTextStyles.caption.copyWith(color: mutedTextColor),
                hintStyle: AppTextStyles.bodyNormal
                    .copyWith(color: mutedTextColor.withValues(alpha: 0.6)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                filled: true,
                fillColor: inputFillColor,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Balance is required';
                }
                final amount = CurrencyFormatter.parse(value, currencyCode: _selectedCurrency);
                if (amount == null) {
                  return 'Invalid balance';
                }
                if (amount > 999999999) {
                  return 'Amount cannot exceed 999.999.999';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),



            Text(
              'Account Type',
              style:
                  AppTextStyles.sectionTitle.copyWith(color: primaryTextColor),
            ),
            const SizedBox(height: AppSizes.sm),

            AccountTypeGridSelector(
              selectedType: _selectedType,
              onTypeSelected: (type) => setState(() => _selectedType = type),
            ),
            const SizedBox(height: AppSizes.xl),

             // Dual Action Buttons xử lý mượt bàn phím ảo và microtask điều hướng
             AppDualActionButtons(
               primaryLabel: widget.actionLabel,
               secondaryLabel: 'Cancel',
               onPrimaryPressed: _isSubmitting
                   ? null
                   : () async {
                       if (!_formKey.currentState!.validate()) return;
                       setState(() {
                         _isSubmitting = true;
                       });
                       final name = _nameController.text.trim();
                       final balance = CurrencyFormatter.parse(_balanceController.text,
                               currencyCode: _selectedCurrency) ??
                           0.0;
                       try {
                         await widget.onSubmit(
                             name, _selectedType, balance, _selectedCurrency);
                       } finally {
                         if (mounted) {
                           setState(() {
                             _isSubmitting = false;
                           });
                         }
                       }
                     },
               onSecondaryPressed: _isSubmitting
                   ? null
                   : () {
                       FocusScope.of(context).unfocus();

                       if (Navigator.canPop(context)) {
                         Future.microtask(() {
                           if (!context.mounted) return;

                           Navigator.pop(context);
                         });
                       }
                     },
             ),
          ],
        ),
      ),
    );
  }
}
