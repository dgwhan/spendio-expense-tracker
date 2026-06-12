import 'package:flutter/material.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class MonthlyBudgetCard extends StatelessWidget {
  final double spent;
  final double budget;
  final int daysLeft;

  const MonthlyBudgetCard({
    super.key,
    required this.spent,
    required this.budget,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (spent / budget).clamp(0.0, 1.0);
    final double remaining = budget - spent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6200EE).withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spent so far',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        CurrencyFormatter.format(spent),
                        style: const TextStyle(
                          color: Color(0xFF0038FF),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' / ${CurrencyFormatter.format(budget)}',
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE8EEFF), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    color: Color(0xFF0038FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF0F2F5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF0038FF)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 18),
          Text.rich(
            TextSpan(
              text: 'You have ',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
              children: [
                TextSpan(
                  text: CurrencyFormatter.format(remaining),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' left for the next $daysLeft days.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
