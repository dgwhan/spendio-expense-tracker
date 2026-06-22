import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/common/app_input_decoration.dart';

class GoalTargetAmountField extends StatelessWidget {
  final TextEditingController controller;

  const GoalTargetAmountField({super.key, required this.controller});

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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: AppInputDecoration.getFieldDecoration(
            context: context,
            labelText: '',
            hintText: '10000000',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty)
              return 'Target amount is required';
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) return 'Invalid target amount';
            return null;
          },
        ),
      ],
    );
  }
}
