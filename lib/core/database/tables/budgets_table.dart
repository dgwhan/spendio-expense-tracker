class BudgetsTable {
  static const tableName = 'budgets';

  static const createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,

      user_id INTEGER NOT NULL,

      name TEXT NOT NULL,

      amount REAL NOT NULL,

      period_type TEXT NOT NULL,

      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,

      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static const createIndexes = [
    '''
    CREATE INDEX IF NOT EXISTS idx_budgets_user_id
    ON budgets(user_id)
    '''
  ];
}
