import 'package:flutter/foundation.dart'; // Bắt buộc để dùng cờ kDebugMode
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.balance,
    required super.currencyCode, 
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
      currencyCode: entity.currencyCode,
      icon: entity.icon,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'wallet_name': name,
      'wallet_type': type.name,
      'balance': balance,
      'currency_code':
          currencyCode, // 🔥 Giữ nguyên đẩy dữ liệu đồng bộ lên Firestore
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final String fallbackId = map['id']?.toString() ?? documentId ?? '';

    // 🔥 CHỐT CHẶN BẢO VỆ GỐC: Tháo ngòi nổ ?? 1 sang ?? 0 kèm log và exception
    final int? rawUserId = (map['user_id'] as num?)?.toInt();
    final int parsedUserId = rawUserId ?? 0;

    if (rawUserId == null) {
      debugPrint(
          '🚨 [AccountModel Data Corruption Error]: "user_id" field is MISSING or NULL inside the database payload! '
          'Wallet ID: $fallbackId, Wallet Name: "${map['wallet_name'] ?? map['name']}". Fallback applied: userId = 0.');

      if (kDebugMode) {
        throw FormatException(
          '🚨 [Critical Model Exception]: Attempted to parse an orphaned Wallet (ID: $fallbackId) with no valid ownership (user_id is null).',
        );
      }
    }

    // 🔥 FIX MẤT TRƯỜNG: Trích xuất currency_code từ payload data, bọc lót nếu trống thì báo 'UNK'
    final String parsedCurrencyCode = map['currency_code']?.toString() ?? 'UNK';

    return AccountModel(
      id: fallbackId,
      userId: parsedUserId,
      name: map['wallet_name']?.toString() ??
          map['name']?.toString() ??
          'Main Wallet',
      type: AccountType.values.firstWhere(
        (e) => e.name == map['wallet_type'] || e.name == map['type'],
        orElse: () => AccountType.cash,
      ),
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      currencyCode:
          parsedCurrencyCode, // 🔥 Đã nạp chuẩn xác trường dữ liệu vào model
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
    String? currencyCode, // 🔥 Cho phép sao chép đổi mã tiền tệ
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
      currencyCode: currencyCode ?? this.currencyCode, // 🔥 Đã bổ sung
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: removeDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  @override
  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      userId: userId,
      name: name,
      type: type,
      balance: balance,
      currencyCode:
          currencyCode, // 🔥 Map ngược lên Entity của Domain Layer để UI hiển thị số dư kèm kí hiệu
      icon: icon,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}
