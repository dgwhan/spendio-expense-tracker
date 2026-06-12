import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountModel({
    required super.id,
    required super.name,
    required super.type,
    required super.balance,
    required super.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountModel.fromEntity(AccountEntity entity, {DateTime? createdAt, DateTime? updatedAt}) {
    return AccountModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      balance: entity.balance,
      icon: entity.icon,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }


  //lưu dữ liệu vào sqflite/firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wallet_name': name,
      'wallet_type': type.name,
      'balance': balance,
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id']?.toString() ?? '',
      name: map['wallet_name']?.toString() ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.name == map['wallet_type'],
        orElse: () => AccountType.cash,
      ),
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      icon: IconData(
        map['icon_code_point'] as int? ?? Icons.wallet.codePoint,
        fontFamily: map['icon_font_family'] as String? ?? 'MaterialIcons',
      ),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
