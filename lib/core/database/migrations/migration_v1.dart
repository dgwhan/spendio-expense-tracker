import 'package:sqflite/sqflite.dart';

import '../tables/users_table.dart';
import '../tables/wallets_table.dart';

class MigrationV1 {
  static Future<void> run(Database db) async {
    await db.execute(UsersTable.createTable);

    await db.execute(WalletsTable.createTable);
  }
}
