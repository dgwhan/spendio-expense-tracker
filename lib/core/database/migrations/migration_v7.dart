import 'package:sqflite/sqflite.dart';

/// Migration v7: Add color column to wallets table
class MigrationV7 {
  static Future<void> run(Database db) async {
    await db.execute(
      'ALTER TABLE wallets ADD COLUMN color INTEGER',
    );
  }
}
