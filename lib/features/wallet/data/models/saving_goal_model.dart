import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';

class SavingGoalModel extends SavingGoalEntity {
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingGoalModel({
    required super.id,
    required super.name,
    required super.currentAmount,
    required super.targetAmount,
    required super.estimatedDate,
    required super.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingGoalModel.fromEntity(SavingGoalEntity entity, {DateTime? createdAt, DateTime? updatedAt}) {
    return SavingGoalModel(
      id: entity.id,
      name: entity.name,
      currentAmount: entity.currentAmount,
      targetAmount: entity.targetAmount,
      estimatedDate: entity.estimatedDate,
      icon: entity.icon,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  //lưu dữ liệu vào sqflite/firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'current_amount': currentAmount,
      'target_amount': targetAmount,
      'estimated_date': estimatedDate.toIso8601String(),
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavingGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingGoalModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0.0,
      targetAmount: (map['target_amount'] as num?)?.toDouble() ?? 0.0,
      estimatedDate: map['estimated_date'] != null 
          ? DateTime.parse(map['estimated_date'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      icon: IconData(
        map['icon_code_point'] as int? ?? Icons.flag.codePoint,
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

  SavingGoalModel copyWith({
    String? id,
    String? name,
    double? currentAmount,
    double? targetAmount,
    DateTime? estimatedDate,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingGoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      estimatedDate: estimatedDate ?? this.estimatedDate,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
