import 'package:flutter/material.dart';

enum AccountType { cash, bank, creditCard, eWallet }

class AccountEntity {
  final String id;
  final int userId;
  final String name;
  final AccountType type;
  final double balance;
  final IconData icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}
