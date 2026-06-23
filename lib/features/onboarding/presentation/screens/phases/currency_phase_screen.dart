import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/onboarding/data/models/currency_item.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_selector_tile.dart';
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import '../../viewmodels/onboarding_viewmodel.dart';

class CurrencyPhaseScreen extends StatefulWidget {
  const CurrencyPhaseScreen({super.key});

  @override
  State<CurrencyPhaseScreen> createState() => _CurrencyPhaseScreenState();
}

class _CurrencyPhaseScreenState extends State<CurrencyPhaseScreen> {
  late CurrencyItem _selectedCurrency;

  @override
  void initState() {
    super.initState();

    final viewModel = context.read<OnboardingViewModel>();
    
    // Tạm thời mặc định là VND
    _selectedCurrency = supportedCurrencies.firstWhere(
      (element) => element.code == 'VND',
      orElse: () => supportedCurrencies.first,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.updateCurrency('VND');
      final profileVM = context.read<ProfileViewModel>();
      profileVM.changeLanguage('vi');
    });
  }

  void _openCurrencyBottomSheet(
      BuildContext context, OnboardingViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.currentLanguage == 'vi'
              ? 'Tính năng chọn quốc gia/tiền tệ sẽ sớm ra mắt! Tạm thời mặc định là VND.'
              : 'Country/currency selection will be coming soon! Temporarily defaulted to VND.',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<OnboardingViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your\npreferred currency',
          style:
              TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 24),
        CurrencySelectorTile(
          selectedCurrency: _selectedCurrency,
          onTap: () => _openCurrencyBottomSheet(context, viewModel),
        ),
      ],
    );
  }
}
