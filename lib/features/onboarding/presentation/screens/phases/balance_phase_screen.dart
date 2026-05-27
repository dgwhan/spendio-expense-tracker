// File: lib/features/onboarding/presentation/screens/phases/balance_phase_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/onboarding_viewmodel.dart';

class BalancePhaseScreen extends StatefulWidget {
  const BalancePhaseScreen({super.key});

  @override
  State<BalancePhaseScreen> createState() => _BalancePhaseScreenState();
}

class _BalancePhaseScreenState extends State<BalancePhaseScreen> {
  final _balanceController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingViewModel>().updateInitialBalance(0);
    });
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    // Lấy mã tiền tệ (VND, USD...) đã chọn từ step trước ra xài nè bấy bì
    final currencyCode = viewModel.currencyCode ?? 'VND';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                currencyCode,
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
