import 'package:sqflite/sqflite.dart';

class MigrationV5 {
  static Future<void> run(Database db) async {
    final List<Map<String, dynamic>> columns = await db.rawQuery('PRAGMA table_info(wallets)');
    final bool columnExists = columns.any((column) => column['name'] == 'deleted_at');
    if (!columnExists) {
      await db.execute('ALTER TABLE wallets ADD COLUMN deleted_at TEXT;');
    }
  }
}
