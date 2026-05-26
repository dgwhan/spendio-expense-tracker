import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_search_bottom_sheet.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_selector_tile.dart';
import 'package:spend_io_app/features/onboarding/data/models/currency_item.dart';

import '../../viewmodels/onboarding_viewmodel.dart';

const List<CurrencyItem> supportedCurrencies = [
  CurrencyItem(countryName: 'Vietnamese', code: 'VND', flag: '🇻🇳'),
  CurrencyItem(countryName: 'United States', code: 'USD', flag: '🇺🇸'),
  CurrencyItem(countryName: 'Europe', code: 'EUR', flag: '🇪🇺'),
  CurrencyItem(countryName: 'Japan', code: 'JPY', flag: '🇯🇵'),
];

class CurrencyAndBalanceScreen extends StatefulWidget {
  const CurrencyAndBalanceScreen({super.key});

  @override
  State<CurrencyAndBalanceScreen> createState() =>
      _CurrencyAndBalanceScreenState();
}

class _CurrencyAndBalanceScreenState extends State<CurrencyAndBalanceScreen> {
  final _balanceController = TextEditingController(text: '0');
  CurrencyItem _selectedCurrency = supportedCurrencies.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<OnboardingViewModel>();
      vm.updateCurrency(_selectedCurrency.code);
      vm.updateInitialBalance(0);
    });
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
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
            _balanceController.text =
                '0'; // Reset ô nhập về 0 khi đổi loại tiền
          });
          viewModel.updateCurrency(newCurrency.code);
          viewModel.updateInitialBalance(0);
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
        // ================= 1. CHOOSE CURRENCY =================
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

        const SizedBox(height: 48),

        // ================= 2. STARTING BALANCE =================
        const Text(
          'Set your starting\nbalance',
          style:
              TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  onChanged: (value) {
                    final parsed = double.tryParse(value) ?? 0;
                    viewModel.updateInitialBalance(parsed);
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                ),
              ),
              Text(
                _selectedCurrency.code,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
