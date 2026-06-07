import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/onboarding_viewmodel.dart';

class BalancePhaseScreen extends StatefulWidget {
  const BalancePhaseScreen({super.key});

  @override
  State<BalancePhaseScreen> createState() => _BalancePhaseScreenState();
}

class _BalancePhaseScreenState extends State<BalancePhaseScreen> {
  late final TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<OnboardingViewModel>();
    final existingBalance = viewModel.initialBalance;

    if (existingBalance != null && existingBalance != 0) {
      final selectedCurrency = viewModel.currencyCode ?? 'VND';
      final formatter = _getFormatter(selectedCurrency);
      final formattedText = formatter.format(existingBalance.toInt());
      _balanceController = TextEditingController(text: formattedText);
    } else {
      _balanceController = TextEditingController(text: '');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.updateInitialBalance(0);
      });
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  NumberFormat _getFormatter(String currencyCode) {
    if (currencyCode == 'USD' || currencyCode == 'EUR') {
      return NumberFormat('#,###', 'en_US');
    }
    return NumberFormat('#,###', 'vi_VN');
  }

  void _onBalanceChanged(
      String value, OnboardingViewModel viewModel, String currencyCode) {
    if (value.isEmpty) {
      viewModel.updateInitialBalance(0);
      return;
    }

    String cleanValue = value.replaceAll(RegExp(r'\D'), '');
    final parsedInt = int.tryParse(cleanValue) ?? 0;
    final parsedDouble = parsedInt.toDouble();

    viewModel.updateInitialBalance(parsedDouble);

    final formatter = _getFormatter(currencyCode);
    final formattedText = formatter.format(parsedInt);

    _balanceController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<OnboardingViewModel>();
    final selectedCurrency =
        context.select((OnboardingViewModel vm) => vm.currencyCode) ?? 'VND';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set your starting\nbalance',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  onChanged: (value) =>
                      _onBalanceChanged(value, viewModel, selectedCurrency),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0047CC).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  selectedCurrency,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0047CC),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
