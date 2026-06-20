// lib/core/database/migrations/migration_v10.dart
import 'package:sqflite/sqflite.dart';
import '../tables/goals_table.dart';
import '../tables/goal_contributions_table.dart';

class MigrationV10 {
  static Future<void> run(Database db) async {
    await db.execute(GoalsTable.createTable);
    await db.execute(GoalContributionsTable.createTable);

    for (final indexStatement in GoalsTable.createIndexes) {
      await db.execute(indexStatement);
    }
    for (final indexStatement in GoalContributionsTable.createIndexes) {
      await db.execute(indexStatement);
    }
  }
}
