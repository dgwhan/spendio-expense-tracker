class FinancialGoalsTable {
  static const tableName = 'financial_goals';

  static const createTable = '''
    CREATE TABLE financial_goals(
      id INTEGER PRIMARY KEY AUTOINCREMENT,

      user_id INTEGER,
      goal_key TEXT,

      created_at TEXT,

      FOREIGN KEY(user_id)
      REFERENCES users(id)
      ON DELETE CASCADE
    )
  ''';
}