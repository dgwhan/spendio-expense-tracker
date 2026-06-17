class CategoriesTable {
  static const tableName = 'categories';

  static const createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,
      user_id INTEGER NOT NULL DEFAULT 0,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      group_name TEXT NOT NULL,
      icon_code_point INTEGER,
      icon_font_family TEXT,
      color_value INTEGER,
      created_at TEXT,
      updated_at TEXT
    )
  ''';
}
