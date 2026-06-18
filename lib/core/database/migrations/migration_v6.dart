import 'package:sqflite/sqflite.dart';

class MigrationV6 {
  static Future<void> run(Database db) async {
    // Reset any old mock budget limits and spent amounts in existing databases
    // await db.execute('UPDATE budget_categories SET budget = 0.0, spent = 0.0;');
  }
}
