import '../../../../core/database/app_database.dart';

class ProfileLocalDataSource {
  Future<void> clearSessionData() async {
    final db = await AppDatabase.database;

    await db.transaction((txn) async {
      await txn.delete('wallets');
      await txn.delete('users');
    });
  }
}
