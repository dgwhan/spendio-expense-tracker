import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/common/app_input_decoration.dart';

class GoalNameField extends StatelessWidget {
  final TextEditingController controller;

  const GoalNameField({super.key, required this.controller});

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
              text: 'Goal Name',
              style: AppTextStyles.sectionTitle.copyWith(color: mutedTextColor),
              children: const [
                TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          textInputAction: TextInputAction.next,
          decoration: AppInputDecoration.getFieldDecoration(
            context: context,
            labelText: '',
            hintText: 'Vacation, New Laptop...',
          ),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Goal name is required'
              : null,
        ),
      ],
    );
  }
}
