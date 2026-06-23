class SavingGoalContributionsTable {
  static const tableName = 'saving_goal_contributions';

  static const createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,
      goal_id TEXT NOT NULL,

      user_id INTEGER NOT NULL,

      amount REAL NOT NULL,

      currency_code TEXT NOT NULL DEFAULT 'USD',

      note TEXT,

      created_at TEXT NOT NULL,
      deleted_at TEXT,

      FOREIGN KEY (goal_id) REFERENCES saving_goals(id)
    )
  ''';

  static const createIndexes = [
    '''
      CREATE INDEX IF NOT EXISTS idx_saving_goal_contributions_goal_id
      ON $tableName(goal_id)
    ''',
    '''
      CREATE INDEX IF NOT EXISTS idx_saving_goal_contributions_user_id
      ON $tableName(user_id)
    ''',
    '''
      CREATE INDEX IF NOT EXISTS idx_saving_goal_contributions_created_at
      ON $tableName(created_at)
    '''
  ];
}
