import 'package:spend_io_app/core/database/tables/budget_categories_table.dart';
import 'package:spend_io_app/core/database/tables/budgets_table.dart';
import 'package:sqflite/sqflite.dart';

class MigrationV9 {
  static Future<void> run(Database db) async {
    await db.execute(BudgetsTable.createTable);

    for (final index in BudgetsTable.createIndexes) {
      await db.execute(index);
    }

    await db.execute(BudgetCategoriesTable.createTable);

    for (final index in BudgetCategoriesTable.createIndexes) {
      await db.execute(index);
    }
  }
}
