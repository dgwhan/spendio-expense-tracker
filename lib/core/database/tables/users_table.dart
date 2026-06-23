class UsersTable {
  static const tableName = 'users';

  static const createTable = '''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,

      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,

      display_name TEXT,
      full_name TEXT,

      occupation TEXT,
      financial_goal TEXT,
      preferred_currency_code TEXT,

      onboarding_completed INTEGER DEFAULT 0,

      created_at TEXT,
      updated_at TEXT,
      last_login_at TEXT
    )
  ''';
}
