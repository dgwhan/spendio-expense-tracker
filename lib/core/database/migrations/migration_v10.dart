// lib/core/database/migrations/migration_v10.dart
import 'package:sqflite/sqflite.dart';
import '../tables/saving_goals_table.dart';
import '../tables/saving_goal_contributions_table.dart';

class MigrationV10 {
  static Future<void> run(Database db) async {
    await db.execute(SavingGoalsTable.createTable);
    await db.execute(SavingGoalContributionsTable.createTable);

    for (final indexStatement in SavingGoalsTable.createIndexes) {
      await db.execute(indexStatement);
    }
    for (final indexStatement in SavingGoalContributionsTable.createIndexes) {
      await db.execute(indexStatement);
    }
  }
}
