import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

class FintechAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final TransactionType selectedType;
  final bool autofocus;

  const FintechAmountInput({
    super.key,
    required this.controller,
    required this.selectedType,
    required this.autofocus,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSizes.md),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              autofocus: autofocus,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: selectedType == TransactionType.expense
                    ? AppColors.error
                    : Colors.green,
              ),
              decoration: const InputDecoration(
                  hintText: '\$0.00', border: InputBorder.none),
              validator: (val) => (val == null ||
                      val.isEmpty ||
                      double.tryParse(val) == null ||
                      double.tryParse(val)! <= 0)
                  ? 'Invalid amount'
                  : null,
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
