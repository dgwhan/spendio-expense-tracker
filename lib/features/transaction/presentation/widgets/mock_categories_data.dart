class MockCategory {
  final String id; // Đổi từ int sang String UUID cố định
  final String name;
  final int colorValue;
  final int iconCodePoint;
  final String? iconFontFamily;

  const MockCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
  });
}

const List<MockCategory> mockCategoriesData = [
  MockCategory(
      id: 'cat_food_drinks',
      name: 'Food & Drinks',
      colorValue: 0xFFFF9800,
      iconCodePoint: 57954),
  MockCategory(
      id: 'cat_shopping',
      name: 'Shopping',
      colorValue: 0xFFE91E63,
      iconCodePoint: 60168),
  MockCategory(
      id: 'cat_transport',
      name: 'Transport',
      colorValue: 0xFF2196F3,
      iconCodePoint: 58673),
  MockCategory(
      id: 'cat_entertainment',
      name: 'Entertainment',
      colorValue: 0xFF9C27B0,
      iconCodePoint: 58941),
  MockCategory(
      id: 'cat_bills_rent',
      name: 'Bills & Rent',
      colorValue: 0xFFF44336,
      iconCodePoint: 57903),
  MockCategory(
      id: 'cat_salary',
      name: 'Salary',
      colorValue: 0xFF4CAF50,
      iconCodePoint: 57895),
  MockCategory(
      id: 'cat_investments',
      name: 'Investments',
      colorValue: 0xFF009688,
      iconCodePoint: 58532),
  MockCategory(
      id: 'cat_others',
      name: 'Others',
      colorValue: 0xFF9E9E9E,
      iconCodePoint: 58361),
];
