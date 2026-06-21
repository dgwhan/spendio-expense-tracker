import 'package:flutter/material.dart';

class GoalTargetAmountField extends StatelessWidget {
  final TextEditingController controller;

  const GoalTargetAmountField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Target Amount',
        hintText: '10000000',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Target amount is required';
        }

        final amount = double.tryParse(value);

        if (amount == null || amount <= 0) {
          return 'Invalid target amount';
        }

        return null;
      },
    );
  }
}
