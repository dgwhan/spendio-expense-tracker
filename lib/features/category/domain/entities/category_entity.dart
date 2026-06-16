class CategoryEntity {
  final String id;
  final int userId;
  final String name;
  final int iconCodePoint;
  final String iconFontFamily;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });
}
