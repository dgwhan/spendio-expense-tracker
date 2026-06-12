import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/auth/presentation/viewmodels/register_form_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/widgets/auth_textfield.dart';

class RegisterFields extends StatefulWidget {
  final RegisterFormViewModel formVM;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onFieldSubmitted;

  const RegisterFields({
    super.key,
    required this.formVM,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onFieldSubmitted,
  });

  @override
  State<RegisterFields> createState() => _RegisterFieldsState();
}

class _RegisterFieldsState extends State<RegisterFields> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: widget.formVM.onEmailChanged,
        ),
        _buildEmailValidationMessage(),
        const SizedBox(height: 16),

        // ================= PASSWORD FIELD =================
        AuthTextField(
          controller: widget.passwordController,
          hintText: 'Password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          onChanged: widget.formVM.onPasswordChanged,
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
        _buildPasswordStrengthMessage(),
        const SizedBox(height: 16),

        // ================= CONFIRM PASSWORD FIELD =================
        AuthTextField(
          controller: widget.confirmPasswordController,
          hintText: 'Confirm password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => widget.onFieldSubmitted(),
          onChanged: widget.formVM.onConfirmPasswordChanged,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textMutedLight,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        _buildConfirmPasswordMessage(),
      ],
    );
  }

  Widget _buildEmailValidationMessage() {
    if (widget.formVM.isEmailChecking) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text('Checking email...',
            style: TextStyle(fontSize: 12, color: AppColors.textMutedLight)),
      );
    }
    if (!widget.formVM.isEmailValidFormat) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text('Invalid email format',
            style: TextStyle(color: AppColors.error, fontSize: 12)),
      );
    }
    if (widget.formVM.isEmailTaken) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text('Email already exists',
            style: TextStyle(color: AppColors.error, fontSize: 12)),
      );
    }
    if (widget.formVM.isEmailValidFormat && !widget.formVM.isEmailTaken) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text('Email available',
            style: TextStyle(color: AppColors.success, fontSize: 12)),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPasswordStrengthMessage() {
    final colors = {
      'Strong': AppColors.success,
      'Medium': AppColors.warning,
      'Weak': AppColors.error,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        'Strength: ${widget.formVM.passwordStrength}',
        style: TextStyle(
          color: colors[widget.formVM.passwordStrength] ?? AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordMessage() {
    if (widget.formVM.passwordMatchMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Text(
          widget.formVM.passwordMatchMessage!,
          style: const TextStyle(color: AppColors.error, fontSize: 12),
        ),
      );
    }
    if (widget.formVM.isPasswordMatch) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text('Passwords match',
            style: TextStyle(color: AppColors.success, fontSize: 12)),
      );
    }
    return const SizedBox.shrink();
  }
}
