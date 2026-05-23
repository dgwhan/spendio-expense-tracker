import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// reusable auth textfield
class AuthTextField
    extends StatelessWidget {
  final TextEditingController
      controller;

  final String hintText;

  final IconData prefixIcon;

  final bool obscureText;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,

      obscureText: obscureText,

      decoration: InputDecoration(
        hintText: hintText,

        prefixIcon: Icon(
          prefixIcon,
        ),

        filled: true,

        fillColor:
            AppColors.lightSurface,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}