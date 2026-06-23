import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'app_currencies.dart';

class CurrencyContext {
  final String preferredCurrencyCode;
  final String locale;

  const CurrencyContext({
    required this.preferredCurrencyCode,
    required this.locale,
  });
}

extension CurrencyContextExtension on BuildContext {
  CurrencyContext get currencyContext {
    try {
      final profileVM = Provider.of<ProfileViewModel>(this, listen: false);

      final preferredCode =
          profileVM.user?.currencyCode ?? AppCurrencies.vndCode;
      final locale = profileVM.currentLanguage == 'vi' ? 'vi_VN' : 'en_US';

      return CurrencyContext(
        preferredCurrencyCode: preferredCode,
        locale: locale,
      );
    } catch (_) {
      return const CurrencyContext(
        preferredCurrencyCode: AppCurrencies.vndCode,
        locale: 'vi_VN',
      );
    }
  }
}
