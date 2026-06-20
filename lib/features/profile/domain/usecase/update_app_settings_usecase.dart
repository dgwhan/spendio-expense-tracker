import 'package:flutter/material.dart';

class AppSettingsParams {
  final bool? isDarkMode;
  final String? languageCode;

  const AppSettingsParams({this.isDarkMode, this.languageCode});
}

class UpdateAppSettingsUseCase {
  const UpdateAppSettingsUseCase();

  Future<void> execute(AppSettingsParams params) async {
    if (params.isDarkMode != null) {
      debugPrint(
          '[USECASE]: Persisting theme parameter setting -> ${params.isDarkMode}');
    }
    if (params.languageCode != null) {
      debugPrint(
          '[USECASE]: Persisting language locale configuration -> ${params.languageCode}');
    }
  }
}
