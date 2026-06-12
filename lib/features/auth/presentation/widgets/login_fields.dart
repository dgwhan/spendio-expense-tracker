import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/auth/presentation/viewmodels/login_form_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/widgets/auth_textfield.dart';

class LoginFields extends StatefulWidget {
  final LoginFormViewModel loginVM;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginFields({
    super.key,
    required this.loginVM,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= EMAIL FIELD =================
        AuthTextField(
          controller: widget.emailController,
          hintText: 'Email address',
          prefixIcon: Icons.email_outlined,
          textInputAction: TextInputAction.next,
          onChanged: widget.loginVM.onEmailChanged,
        ),
        _buildEmailValidationMessage(),
        const SizedBox(height: 16),

        // ================= PASSWORD FIELD =================
        AuthTextField(
          controller: widget.passwordController,
          hintText: 'Password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onChanged: widget.loginVM.onPasswordChanged,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textMutedLight,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        _buildPasswordValidationMessage(),
      ],
    );
  }

  Widget _buildEmailValidationMessage() {
    if (widget.loginVM.isEmailEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text(
          'Email is required',
          style: TextStyle(color: AppColors.error, fontSize: 12),
        ),
      );
    }
    if (!widget.loginVM.isEmailValidFormat) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text(
          'Invalid email format',
          style: TextStyle(color: AppColors.error, fontSize: 12),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPasswordValidationMessage() {
    if (widget.loginVM.isPasswordEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text(
          'Password is required',
          style: TextStyle(color: AppColors.error, fontSize: 12),
        ),
      );
    }
    if (widget.passwordController.text.length < 6) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text(
          'Minimum 6 characters',
          style: TextStyle(color: AppColors.error, fontSize: 12),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
