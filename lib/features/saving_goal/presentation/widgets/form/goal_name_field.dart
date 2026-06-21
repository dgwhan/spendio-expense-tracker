import 'package:flutter/material.dart';

class GoalNameField extends StatelessWidget {
  final TextEditingController controller;

  const GoalNameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Goal Name',
        hintText: 'Vacation, New Laptop...',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Goal name is required';
        }
        return null;
      },
    );
  }
}
