class FinancialGoalsTable {
  static const tableName = 'financial_goals';

  static const createTable = '''
    CREATE TABLE financial_goals(
      id TEXT PRIMARY KEY,

      user_id INTEGER,

      name TEXT,

      current_amount REAL DEFAULT 0,

      target_amount REAL DEFAULT 0,

      estimated_date TEXT,

      icon_code_point INTEGER,

      icon_font_family TEXT,

      created_at TEXT,

      updated_at TEXT,

      FOREIGN KEY(user_id)
      REFERENCES users(id)
      ON DELETE CASCADE
    )
  ''';
}