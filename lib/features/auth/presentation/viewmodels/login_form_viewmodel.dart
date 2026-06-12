import 'package:flutter/material.dart';

class LoginFormViewModel extends ChangeNotifier {
  String email = '';
  String password = '';

  bool isEmailValidFormat = false;
  bool isEmailEmpty = true;
  bool isPasswordEmpty = true;

  bool isFormValid = false;

  bool _validateEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
  }

  void onEmailChanged(String value) {
    email = value.trim();

    isEmailEmpty = email.isEmpty;
    isEmailValidFormat = !isEmailEmpty && _validateEmail(email);

    _validateForm();
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    password = value;

    isPasswordEmpty = password.isEmpty;

    _validateForm();
    notifyListeners();
  }

  void _validateForm() {
    isFormValid =
        !isEmailEmpty &&
        isEmailValidFormat &&
        !isPasswordEmpty &&
        password.length >= 6;
  }

  void clearForm() {
    email = '';
    password = '';
    isEmailValidFormat = false;
    isEmailEmpty = true;
    isPasswordEmpty = true;
    isFormValid = false;
    notifyListeners();
  }
}