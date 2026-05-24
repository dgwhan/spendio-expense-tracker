import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/check_email_usecase.dart';

class RegisterFormViewModel extends ChangeNotifier {
  final CheckEmailUseCase checkEmailUseCase;

  RegisterFormViewModel({
    required this.checkEmailUseCase,
  });

  // state
  String email = '';
  String password = '';
  String confirmPassword = '';

  bool isEmailValidFormat = false;
  bool isEmailChecking = false;
  bool isEmailTaken = false;

  String passwordStrength = '';

  String? get passwordMatchMessage {
    if (confirmPassword.isEmpty) return null;
    if (password == confirmPassword) return null;
    return "Passwords do not match";
  }
  
  bool get isPasswordMatch =>
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword;
        
  Timer? _debounce;

  bool get isFormValid =>
      isEmailValidFormat &&
      !isEmailTaken &&
      password.length >= 6 &&
      password == confirmPassword;

  

  void onEmailChanged(String value) {
    email = value.trim();
    isEmailValidFormat = _validateEmail(email);
    isEmailTaken = false;

    notifyListeners();

    _debounce?.cancel();

    if (!isEmailValidFormat) return;

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      isEmailChecking = true;
      notifyListeners();

      final exists = await checkEmailUseCase(email);

      isEmailTaken = exists;
      isEmailChecking = false;

      notifyListeners();
    });
  }

  void onPasswordChanged(String value) {
    password = value;

    if (value.length < 6) {
      passwordStrength = 'Weak';
    } else if (value.length < 10) {
      passwordStrength = 'Medium';
    } else {
      passwordStrength = 'Strong';
    }

    notifyListeners();
  }

  void onConfirmPasswordChanged(String value) {
    confirmPassword = value;
    notifyListeners();
  }

  bool _validateEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}