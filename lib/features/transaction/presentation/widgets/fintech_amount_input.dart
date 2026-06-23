import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class FintechAmountInput extends StatefulWidget {
  final TextEditingController controller;
  final TransactionType selectedType;
  final bool autofocus;
  final String currencyCode;

  const FintechAmountInput({
    super.key,
    required this.controller,
    required this.selectedType,
    required this.autofocus,
    required this.currencyCode,
  });

  @override
  State<FintechAmountInput> createState() {
    return _FintechAmountInputState();
  }
}

class _FintechAmountInputState extends State<FintechAmountInput> {
  String? _dynamicErrorText;

  @override
  void initState() {
    super.initState();
    _validateAmount(widget.controller.text);
  }

  @override
  void didUpdateWidget(covariant FintechAmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.text != oldWidget.controller.text) {
      _validateAmount(widget.controller.text);
    }
  }

  void _validateAmount(String value) {
    if (value.trim().isEmpty) {
      if (_dynamicErrorText != null) {
        setState(() {
          _dynamicErrorText = null;
        });
      }
      return;
    }

    final amount =
        CurrencyFormatter.parse(value, currencyCode: widget.currencyCode);

    if (amount == null || amount <= 0) {
      if (_dynamicErrorText != AppLocalizations.translate('Invalid amount')) {
        setState(() {
          _dynamicErrorText = AppLocalizations.translate('Invalid amount');
        });
      }
    } else if (amount > 999999999) {
      final targetError =
          AppLocalizations.translate('Amount cannot exceed 999.999.999');
      if (_dynamicErrorText != targetError) {
        setState(() {
          _dynamicErrorText = targetError;
        });
      }
    } else {
      if (_dynamicErrorText != null) {
        setState(() {
          _dynamicErrorText = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = widget.selectedType == TransactionType.expense;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;
    final hintColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final amountColor = isExpense ? AppColors.expense : AppColors.income;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.xs),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.translate('Amount')}*',
              style: AppTextStyles.caption.copyWith(
                color: _dynamicErrorText != null ? AppColors.error : hintColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: widget.controller,
              keyboardType: TextInputType.number,
              autofocus: widget.autofocus,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: amountColor,
                letterSpacing: -0.4,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: hintColor.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
              inputFormatters: [
                _CoreCurrencyWithoutSuffixFormatter(
                  currencyCode: widget.currencyCode,
                  locale: context.currencyContext.locale,
                ),
              ],
              onChanged: (val) {
                _validateAmount(val);
              },
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return AppLocalizations.translate('Amount cannot be empty');
                }
                final amount = CurrencyFormatter.parse(val,
                    currencyCode: widget.currencyCode);
                if (amount == null || amount <= 0 || amount > 999999999) {
                  return '';
                }
                return null;
              },
            ),
            if (_dynamicErrorText != null) ...[
              const SizedBox(height: 6),
              Text(
                _dynamicErrorText!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CoreCurrencyWithoutSuffixFormatter extends TextInputFormatter {
  final String currencyCode;
  final String locale;

  _CoreCurrencyWithoutSuffixFormatter({
    required this.currencyCode,
    required this.locale,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Chỉ giữ lại các chữ số
    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    double amount = double.parse(cleanText);
    String formattedText = formatCurrency(
      amount,
      currencyCode: currencyCode,
      locale: locale,
    );

    // Xóa tất cả các ký tự tiền tệ và khoảng trắng dư thừa, chỉ giữ lại số và phân cách hàng nghìn
    formattedText = formattedText
        .replaceAll('đ', '')
        .replaceAll('\$', '')
        .replaceAll('VND', '')
        .replaceAll('USD', '')
        .trim();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
