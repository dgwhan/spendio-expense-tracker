class BudgetCategoriesTable {
  static const tableName = 'budget_categories';

  static const createTable = '''
    CREATE TABLE IF NOT EXISTS budget_categories(
      id TEXT PRIMARY KEY,
      user_id INTEGER,
      name TEXT,
      spent REAL DEFAULT 0,
      budget REAL DEFAULT 0,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';
}
