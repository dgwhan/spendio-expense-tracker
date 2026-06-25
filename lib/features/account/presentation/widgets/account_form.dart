import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/common/app_dual_action_buttons.dart';
import 'package:spend_io_app/core/widgets/button/app_action_button.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_type_grid_selector.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/currency_input_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class AccountForm extends StatefulWidget {
  final AccountEntity? account;
  final String actionLabel;
  final Future<void> Function(
          String name, AccountType type, double balance, String currencyCode)
      onSubmit;

  const AccountForm({
    super.key,
    this.account,
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

    if (widget.account != null) {
      final formatter = NumberFormat.decimalPattern('vi_VN');
      final String initialFormatted =
          formatter.format(widget.account!.balance.round());
      _balanceController = TextEditingController(text: initialFormatted);
    } else {
      _balanceController = TextEditingController(text: '');
    }

    if (widget.account == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCurrency = context.currencyContext.preferredCurrencyCode;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Widget _buildFieldTitle(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2, top: AppSizes.md),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
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

    final baseInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 1.0),
    );

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Name
            _buildFieldTitle('Account Name', mutedTextColor),
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.bodyNormal.copyWith(
                  color: primaryTextColor, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'e.g. My Savings, Daily Cash',
                hintStyle: AppTextStyles.bodyNormal.copyWith(
                    color: mutedTextColor.withValues(alpha: 0.5), fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: 14),
                enabledBorder: baseInputBorder,
                focusedBorder: baseInputBorder.copyWith(
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5)),
                errorBorder: baseInputBorder.copyWith(
                    borderSide: const BorderSide(color: AppColors.error)),
                focusedErrorBorder: baseInputBorder.copyWith(
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 1.5)),
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

            // Initial Balance
            _buildFieldTitle('Initial Balance', mutedTextColor),
            TextFormField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyNormal.copyWith(
                  color: primaryTextColor, fontWeight: FontWeight.w600),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                // Bộ formatter đã gỡ chặn cứng ở bước trước giúp người dùng nhập tùy thích
                CurrencyInputFormatter(currencyCode: _selectedCurrency),
              ],
              decoration: InputDecoration(
                hintText: '0',
                suffixText: _selectedCurrency,
                suffixStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: 14),
                enabledBorder: baseInputBorder,
                focusedBorder: baseInputBorder.copyWith(
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5)),
                errorBorder: baseInputBorder.copyWith(
                    borderSide: const BorderSide(color: AppColors.error)),
                focusedErrorBorder: baseInputBorder.copyWith(
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 1.5)),
                filled: true,
                fillColor: inputFillColor,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Balance is required';
                }
                final amount = CurrencyFormatter.parse(value,
                    currencyCode: _selectedCurrency);
                if (amount == null) return 'Invalid balance';

                if (amount > 10000000000) {
                  return 'Amount cannot exceed 10.000.000.000';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),

            // Selector
            Text(
              'Account Type',
              style: AppTextStyles.sectionTitle.copyWith(
                  color: primaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            AccountTypeGridSelector(
              selectedType: _selectedType,
              onTypeSelected: (type) => setState(() => _selectedType = type),
            ),

            const SizedBox(height: 40),

            // BUTTONS ĐÔI HỆ THỐNG
            AppDualActionButtons(
              primaryLabel: 'Cancel',
              secondaryLabel: _isSubmitting ? 'Saving...' : widget.actionLabel,
              primaryVariant: AppActionButtonVariant.cancel,
              secondaryVariant: AppActionButtonVariant.primary,
              onPrimaryPressed: _isSubmitting
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
              onSecondaryPressed: _isSubmitting
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _isSubmitting = true);

                      final name = _nameController.text.trim();
                      final balance = CurrencyFormatter.parse(
                              _balanceController.text,
                              currencyCode: _selectedCurrency) ??
                          0.0;

                      try {
                        await widget.onSubmit(
                            name, _selectedType, balance, _selectedCurrency);
                      } finally {
                        if (mounted) setState(() => _isSubmitting = false);
                      }
                    },
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}
