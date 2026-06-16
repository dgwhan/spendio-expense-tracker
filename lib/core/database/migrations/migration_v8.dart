import 'package:sqflite/sqflite.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

class MigrationV8 {
  static Future<void> run(Database db) async {
    await db.execute(CategoriesTable.createTable);
    await db.execute(TransactionsTable.createTable);
  }
}
