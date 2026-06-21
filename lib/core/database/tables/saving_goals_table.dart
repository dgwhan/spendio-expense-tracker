class SavingGoalsTable {
  static const tableName = 'saving_goals';

  static const createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,

      user_id INTEGER NOT NULL,

      title TEXT NOT NULL,

      target_amount REAL NOT NULL,
      initial_amount REAL DEFAULT 0,

      cached_current_amount REAL DEFAULT 0,
      cached_progress REAL DEFAULT 0,

      icon_code_point INTEGER,
      icon_font_family TEXT,

      color_value INTEGER,

      status TEXT DEFAULT 'active',

      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,

      deleted_at TEXT
    )
  ''';

  static const createIndexes = [
    '''
      CREATE INDEX IF NOT EXISTS idx_goals_user_id
      ON $tableName(user_id)
    ''',
    '''
      CREATE INDEX IF NOT EXISTS idx_goals_status
      ON $tableName(status)
    '''
  ];
}
