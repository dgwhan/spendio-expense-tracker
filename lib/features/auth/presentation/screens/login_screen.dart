import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_strings.dart';
import 'package:spend_io_app/core/dialogs/app_dialogs.dart';
import 'package:spend_io_app/core/theme/text_styles.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/button/app_button.dart';
import 'package:spend_io_app/core/widgets/button/app_text_button.dart';

import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/auth/presentation/screens/register_screen.dart';
import 'package:spend_io_app/features/auth/presentation/viewmodels/login_form_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/widgets/login_fields.dart';
import 'package:spend_io_app/features/splash/presentation/screens/splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginFormViewModel>().clearForm();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Email / Password Login
  // ──────────────────────────────────────────────

  Future<void> login() async {
    final authProvider = context.read<AuthProvider>();

    // Chặn double-click và multiple submit
    if (authProvider.isLoading) return;

    final emailText = emailController.text.trim();
    final passwordText = passwordController.text.trim();

    // 1. Kiểm tra tất cả field trước khi submit
    if (emailText.isEmpty || passwordText.isEmpty) {
      await AppDialogs.warning(
        context: context,
        title: AppStrings.warningTitle,
        content: AppStrings.errorEmptyFields,
      );
      return;
    }

    // Email sai format => AppDialogs.warning
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegex.hasMatch(emailText)) {
      await AppDialogs.warning(
        context: context,
        title: AppStrings.warningTitle,
        content: AppStrings.errorInvalidEmail,
      );
      return;
    }

    // Password không đạt yêu cầu => AppDialogs.warning
    if (passwordText.length < 6) {
      await AppDialogs.warning(
        context: context,
        title: AppStrings.warningTitle,
        content: AppStrings.errorPasswordLength,
      );
      return;
    }

    // 2. Thực hiện đăng nhập (gọi usecase/repository qua authProvider)
    final String? errorMessage = await authProvider.login(
      email: emailText,
      password: passwordText,
    );

    if (!mounted) return;

    if (errorMessage == null) {
      // Thành công => AppDialogs.success + điều hướng
      await AppDialogs.success(
        context: context,
        title: AppStrings.successTitle,
        content: AppStrings.successLogin,
        onConfirm: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => false,
          );
        },
      );
    } else {
      // Thất bại => AppDialogs.error hoặc networkError
      if (errorMessage.contains('network') ||
          errorMessage.contains('SocketException')) {
        await AppDialogs.networkError(
          context: context,
          title: AppStrings.networkErrorTitle,
          content: AppStrings.networkErrorMessage,
        );
      } else {
        await AppDialogs.error(
          context: context,
          title: AppStrings.errorTitle,
          content: AppStrings.errorLogin,
        );
      }
    }
  }

  // ──────────────────────────────────────────────
  // Google Sign-In
  // ──────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoading) return;

    final String? errorMessage = await authProvider.signInWithGoogle();

    if (!mounted) return;

    // User cancelled the Google picker — no error, no navigation
    if (errorMessage == null && authProvider.currentUser == null) return;

    if (errorMessage == null) {
      // Success — go to SplashScreen (handles onboarding redirect internally)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } else {
      await AppDialogs.error(
        context: context,
        title: AppStrings.errorTitle,
        content: AppStrings.errorGoogleSignIn,
      );
    }
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final loginVM = context.watch<LoginFormViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppHeader(
        title: '',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: TextStyles.heading1(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 32),
              LoginFields(
                loginVM: loginVM,
                emailController: emailController,
                passwordController: passwordController,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: AppTextButton(
                  text: 'Forgot password?',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  onTap: () {
                    // Xử lý quên mật khẩu
                  },
                ),
              ),
              const SizedBox(height: 32),

              // ── Primary Sign In ─────────────────
              AppButton(
                title: 'Sign In',
                isLoading: authProvider.isEmailLoading,
                variant: AppButtonVariant.primary,
                onPressed: login,
              ),
              const SizedBox(height: 24),

              // ── OR Divider ──────────────────────
              _buildDivider(),
              const SizedBox(height: 24),

              // ── Google Sign-In Button ───────────
              _buildGoogleSignInButton(authProvider.isGoogleLoading),
              const SizedBox(height: 32),

              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── "or continue with" divider ────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.borderLight,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMutedLight,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.borderLight,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // ── Google Sign-In Button ─────────────────────────────────────────────────
  Widget _buildGoogleSignInButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceLight,
          side: BorderSide(
            color: AppColors.borderLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleLogoSvg(),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyles.bodyMedium(color: AppColors.textSecondaryLight),
        ),
        AppTextButton(
          text: 'Register',
          fontWeight: FontWeight.w600,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
        ),
      ],
    );
  }
}

// ── Google 'G' Logo (inline SVG — no external asset dependency) ───────────────
class _GoogleLogoSvg extends StatelessWidget {
  const _GoogleLogoSvg();

  static const String _svgSource = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="22" height="22">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svgSource,
      width: 22,
      height: 22,
    );
  }
}
