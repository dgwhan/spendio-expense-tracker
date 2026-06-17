class CategoryEntity {
  final String id;
  final int userId;
  final String name;
  final String type;
  final String groupName;
  final int iconCodePoint;
  final String? iconFontFamily;
  final int colorValue;
  final String? createdAt;
  final String? updatedAt;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.groupName,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    required this.colorValue,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          type == other.type &&
          groupName == other.groupName &&
          iconCodePoint == other.iconCodePoint &&
          iconFontFamily == other.iconFontFamily &&
          colorValue == other.colorValue &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      type.hashCode ^
      groupName.hashCode ^
      iconCodePoint.hashCode ^
      iconFontFamily.hashCode ^
      colorValue.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
