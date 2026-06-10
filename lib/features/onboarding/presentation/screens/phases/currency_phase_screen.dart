import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/onboarding/data/models/currency_item.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_search_bottom_sheet.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_selector_tile.dart';
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
    final savedCode = viewModel.currencyCode;

    if (savedCode != null) {
      _selectedCurrency = supportedCurrencies.firstWhere(
        (element) => element.code == savedCode,
        orElse: () => supportedCurrencies.first,
      );
    } else {
      _selectedCurrency = supportedCurrencies.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.updateCurrency(_selectedCurrency.code);
      });
    }
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
