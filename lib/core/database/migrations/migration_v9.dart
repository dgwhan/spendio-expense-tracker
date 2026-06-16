import 'package:sqflite/sqflite.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

class MigrationV9 {
  static Future<void> run(Database db) async {
    await db.execute('DROP TABLE IF EXISTS transactions');
    await db.execute('DROP TABLE IF EXISTS categories');
    await db.execute(CategoriesTable.createTable);
    await db.execute(TransactionsTable.createTable);

    // Seed default transaction categories — user_id 0 = global/shared
    // These are not user-scoped; all users share the same category pool.
    final now = DateTime.now().toIso8601String();
    final seedCategories = [
      {
        'id': 'cat_food_drinks',
        'name': 'Food & Drinks',
        'icon_code_point': 57954,
        'icon_font_family': 'MaterialIcons',
        'color_value': 0xFFFF9800
      },
      {
        'id': 'cat_shopping',
        'name': 'Shopping',
        'icon_code_point': 60168,
        'icon_font_family': 'MaterialIcons',
        'color_value': 0xFFE91E63
      },
      {
        'id': 'cat_transport',
        'name': 'Transport',
        'icon_code_point': 58673,
        'icon_font_family': 'MaterialIcons',
        'color_value': 0xFF2196F3
      },
      {
        'id': 'cat_entertainment',
        'name': 'Entertainment',
        'icon_code_point': 58941,
        'icon_font_family': 'MaterialIcons',
        'color_value': 0xFF9C27B0
      },
      {
        'id': 'cat_bills_rent',
        'name': 'Bills & Rent',
        'icon_code_point': 57903,
        'icon_font_family': 'MaterialIcons',
        'color_value': 0xFFF44336
      },
      {
        'id': 'cat_salary',
        'name': 'Salary',
        'icon_code_point': 57895,
        'icon_font_family': 'MaterialIcons',
        'color_value': 0xFF4CAF50
      },
      {
        'id': 'cat_investments',
        'name': 'Investments',
        'icon_code_point': 58532,
        'icon_font_family': 'MaterialIcons',
        'color_value': 0xFF009688
      },
      {
        'id': 'cat_others',
        'name': 'Others',
        'icon_code_point': 58361,
        'icon_font_family': 'MaterialIcons',
        'color_value': 0xFF9E9E9E
      },
    ];

    for (final cat in seedCategories) {
      await db.insert('categories', {
        ...cat,
        'user_id': 0,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}
