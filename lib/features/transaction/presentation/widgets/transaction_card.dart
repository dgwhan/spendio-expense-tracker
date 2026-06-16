import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TransactionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == TransactionType.income;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.add_circle : Icons.remove_circle,
          color: isIncome ? Colors.green : Colors.red,
        ),
        title: Text(title),
        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? "+" : "-"}\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
