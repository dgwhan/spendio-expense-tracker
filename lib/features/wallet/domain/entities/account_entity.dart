import 'package:flutter/material.dart';

enum AccountType {
  cash,
  bank,
  creditCard,
  eWallet,
}

class AccountEntity {
  final String name;
  final AccountType type;
  final double balance;
  final IconData icon;

  const AccountEntity({
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
  });
}
