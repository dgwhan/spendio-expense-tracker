import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.groupName,
    required super.iconCodePoint,
    super.iconFontFamily,
    required super.colorValue,
    super.createdAt,
    super.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'group_name': groupName,
      'icon_code_point': iconCodePoint,
      'icon_font_family': iconFontFamily ?? 'MaterialIcons',
      'color_value': colorValue,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as int? ?? 0,
      name: map['name'] as String,
      type: map['type'] as String,
      groupName: map['group_name'] as String,
      iconCodePoint: map['icon_code_point'] as int,
      iconFontFamily: map['icon_font_family'] as String? ?? 'MaterialIcons',
      colorValue: map['color_value'] as int,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
