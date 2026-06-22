import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

import 'package:spend_io_app/core/utils/currency_formatter.dart';

class FintechAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final TransactionType selectedType;
  final bool autofocus;

  const FintechAmountInput({
    super.key,
    required this.controller,
    required this.selectedType,
    required this.autofocus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final amountColor = selectedType == TransactionType.expense
        ? AppColors.expense
        : AppColors.income;

    final hintColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: autofocus,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: amountColor,
                letterSpacing: -1.0,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: hintColor.withValues(alpha: 0.4),
                ),
                // TRIỆT TIÊU TOÀN BỘ CÁC LOẠI BORDER TRONG MỌI TRẠNG THÁI
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                errorStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CoreCurrencyWithoutSuffixFormatter(),
              ],
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter an amount';
                }
                final cleanVal = val.replaceAll('.', '');
                final amount = int.tryParse(cleanVal);
                if (amount == null || amount <= 0) {
                  return 'Invalid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }
}

class _CoreCurrencyWithoutSuffixFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final double amount = double.parse(cleanText);

    String formattedText = formatCurrency(amount);

    formattedText = formattedText.replaceAll('đ', '').trim();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
