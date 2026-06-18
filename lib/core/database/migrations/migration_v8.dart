import 'package:sqflite/sqflite.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';
import '../../../core/utils/app_default_categories.dart';

class MigrationV8 {
  static Future<void> run(Database db) async {
    // 1. Drop existing tables to ensure the new columns (type, group_name) are created properly
    await db.execute('DROP TABLE IF EXISTS ${TransactionsTable.tableName}');
    await db.execute('DROP TABLE IF EXISTS ${CategoriesTable.tableName}');

    // 2. Execute fresh table creation scripts
    await db.execute(CategoriesTable.createTable);
    await db.execute(TransactionsTable.createTable);

    // 3. Populate default global category seed data
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();

    for (final category in AppDefaultCategories.rawSeedData) {
      batch.insert(CategoriesTable.tableName, {
        ...category,
        'user_id': 0, // Global system-defined identifier
        'icon_font_family': 'MaterialIcons',
        'created_at': now,
        'updated_at': now,
      });
    }
    await batch.commit(noResult: true);
  }
  
}
