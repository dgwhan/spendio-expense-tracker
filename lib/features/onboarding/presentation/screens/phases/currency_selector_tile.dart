import 'package:flutter/material.dart';
import 'package:spend_io_app/features/onboarding/data/models/currency_item.dart';

class CurrencySelectorTile extends StatelessWidget {
  final CurrencyItem selectedCurrency;
  final VoidCallback onTap;

  const CurrencySelectorTile({
    super.key,
    required this.selectedCurrency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(selectedCurrency.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              selectedCurrency.countryName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              selectedCurrency.code,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
