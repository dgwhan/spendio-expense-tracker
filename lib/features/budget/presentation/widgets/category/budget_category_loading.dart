import 'package:flutter/material.dart';

class BudgetCategoryLoading extends StatelessWidget {
  final double height;
  const BudgetCategoryLoading({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]!.withValues(alpha: 0.5)
            : Colors.grey[100]!,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.grey),
          ),
        ),
      ),
    );
  }
}
