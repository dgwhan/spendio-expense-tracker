import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/common/app_input_decoration.dart';

class GoalInitialAmountField extends StatefulWidget {
  final TextEditingController controller;
  const GoalInitialAmountField({super.key, required this.controller});

  @override
  State<GoalInitialAmountField> createState() => _GoalInitialAmountFieldState();
}

class _GoalInitialAmountFieldState extends State<GoalInitialAmountField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.controller.text == '0') {
      widget.controller.clear();
    } else if (!_focusNode.hasFocus && widget.controller.text.trim().isEmpty) {
      widget.controller.text = '0';
    }
  }

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
          child: Text('Initial Amount',
              style:
                  AppTextStyles.sectionTitle.copyWith(color: mutedTextColor)),
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
          ],
          decoration: AppInputDecoration.getFieldDecoration(
            context: context,
            labelText: '',
            hintText: '0',
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final amount = double.tryParse(value);
              if (amount == null || amount < 0) return 'Invalid amount';
            }
            return null;
          },
        ),
      ],
    );
  }
}
