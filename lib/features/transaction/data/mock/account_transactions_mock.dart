// ✓ CLEAN IMPORTS: Không còn import package:flutter/material.dart ở đây nữa
import 'package:spend_io_app/features/transaction/data/models/transaction_model.dart';

/// [App Location] Data layer mock factory -> Exclusively for development environments.
/// [Core Function] Generates structured mock ledger history for a specific account, using clean string-based colors/icons.
List<TransactionModel> generateMockTransactions(String accountId) {
  final now = DateTime.now();

  return [
    TransactionModel(
      id: 'tx_1',
      title: 'Starbucks Coffee',
      amount: 65000,
      date: now.subtract(const Duration(hours: 2)),
      category: 'Food & Drink',
      isExpense: true,
      categoryIconCode: 'local_dining_outlined',
      categoryColorHex: 'FF9F43', // Mã màu cam thô dạng Hex string
    ),
    TransactionModel(
      id: 'tx_2',
      title: 'Monthly Salary',
      amount: 15000000,
      date: now.subtract(const Duration(days: 1, hours: 4)),
      category: 'Salary',
      isExpense: false,
      categoryIconCode: 'monetization_on_outlined',
      categoryColorHex: '28C76F', // Mã màu xanh lá dạng Hex string
    ),
    TransactionModel(
      id: 'tx_3',
      title: 'Grab Bike Ride',
      amount: 22000,
      date: now.subtract(const Duration(days: 2)),
      category: 'Transport',
      isExpense: true,
      categoryIconCode: 'directions_bike_outlined',
      categoryColorHex: '00CFDD', // Mã màu xanh dương dạng Hex string
    ),
  ];
}
