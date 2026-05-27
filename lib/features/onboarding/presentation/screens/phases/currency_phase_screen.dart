// File: lib/features/onboarding/presentation/screens/phases/currency_phase_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/onboarding/data/models/currency_item.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_search_bottom_sheet.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_selector_tile.dart';

import '../../viewmodels/onboarding_viewmodel.dart';

const List<CurrencyItem> supportedCurrencies = [
  CurrencyItem(countryName: 'Vietnamese', code: 'VND', flag: '🇻🇳'),
  CurrencyItem(countryName: 'United States', code: 'USD', flag: '🇺🇸'),
  CurrencyItem(countryName: 'Europe', code: 'EUR', flag: '🇪🇺'),
  CurrencyItem(countryName: 'Japan', code: 'JPY', flag: '🇯🇵'),
];

class CurrencyPhaseScreen extends StatefulWidget {
  const CurrencyPhaseScreen({super.key});

  @override
  State<CurrencyPhaseScreen> createState() => _CurrencyPhaseScreenState();
}

class _CurrencyPhaseScreenState extends State<CurrencyPhaseScreen> {
  CurrencyItem _selectedCurrency = supportedCurrencies.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OnboardingViewModel>()
          .updateCurrency(_selectedCurrency.code);
    });
  }

  void _openCurrencyBottomSheet(
      BuildContext context, OnboardingViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CurrencySearchBottomSheet(
        currentSelection: _selectedCurrency,
        onCurrencySelected: (newCurrency) {
          setState(() {
            _selectedCurrency = newCurrency;
          });
          viewModel.updateCurrency(newCurrency.code);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();

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
