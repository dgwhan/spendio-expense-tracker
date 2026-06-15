import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.balance,
    required super.icon,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      balance: entity.balance,
      icon: entity.icon,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'wallet_name': name,
      'wallet_type': type.name,
      'balance': balance,
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id']?.toString() ?? '',
      userId: (map['user_id'] as num?)?.toInt() ?? 1,
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
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
    );
  }

  @override
  AccountModel copyWith({
    String? id,
    int? userId,
    String? name,
    AccountType? type,
    double? balance,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool removeDeletedAt = false,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: removeDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
