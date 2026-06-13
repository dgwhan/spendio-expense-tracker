import '../../domain/entities/budget_category_entity.dart';

class BudgetCategoryModel {
  final String id;
  final String name;
  final double spent;
  final double budget;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetCategoryModel({
    required this.id,
    required this.name,
    required this.spent,
    required this.budget,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Map raw database values
  factory BudgetCategoryModel.fromMap(Map<String, dynamic> map) {
    return BudgetCategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      spent: (map['spent'] as num?)?.toDouble() ?? 0.0,
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to SQLite insert map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'spent': spent,
      'budget': budget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map to domain entity
  BudgetCategoryEntity toEntity() {
    return BudgetCategoryEntity(
      id: id,
      name: name,
      spent: spent,
      budget: budget,
    );
  }

  /// Map from domain entity
  factory BudgetCategoryModel.fromEntity(
    BudgetCategoryEntity entity, {
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetCategoryModel(
      id: entity.id,
      name: entity.name,
      spent: entity.spent,
      budget: entity.budget,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
