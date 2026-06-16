import 'package:flutter/material.dart';

enum AccountType { cash, bank, creditCard, eWallet, other }

class AccountEntity {
  final String id;
  final int userId;
  final String name;
  final AccountType type;
  final double balance;
  final String currencyCode;
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
    required this.currencyCode,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  AccountEntity copyWith({
    String? id,
    int? userId,
    String? name,
    AccountType? type,
    double? balance,
    String? currencyCode,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currencyCode: currencyCode ?? this.currencyCode,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory AccountEntity.empty() {
    return AccountEntity(
      id: '',
      userId: 0,
      name: 'Unknown Wallet',
      type: AccountType.other,
      balance: 0.0,
      currencyCode: 'UNK',
      icon: Icons.wallet,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
