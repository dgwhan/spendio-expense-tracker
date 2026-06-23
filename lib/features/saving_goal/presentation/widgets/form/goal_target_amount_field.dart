import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/common/app_input_decoration.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/currency_input_formatter.dart';

class GoalTargetAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String currencyCode;

  const GoalTargetAmountField({
    super.key,
    required this.controller,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              text: 'Target Amount',
              style: AppTextStyles.sectionTitle.copyWith(color: mutedTextColor),
              children: const [
                TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(currencyCode: currencyCode),
          ],
          decoration: AppInputDecoration.getFieldDecoration(
            context: context,
            labelText: '',
            hintText: '0',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Target amount is required';
            }
            final amount = CurrencyFormatter.parse(value, currencyCode: currencyCode);
            if (amount == null || amount <= 0) return 'Invalid target amount';
            if (amount > 999999999) {
              return 'Amount cannot exceed 999.999.999';
            }
            return null;
          },
        ),
      ],
    );
  }
}
