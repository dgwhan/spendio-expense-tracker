import 'package:sqflite/sqflite.dart';
import '../tables/budget_categories_table.dart';

class MigrationV4 {
  static Future<void> run(Database db) async {
    await db.execute(BudgetCategoriesTable.createTable);
  }
}
