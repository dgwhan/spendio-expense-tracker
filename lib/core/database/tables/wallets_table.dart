class WalletsTable {
  static const tableName = 'wallets';

  static const createTable = '''
    CREATE TABLE wallets(
      id TEXT PRIMARY KEY,

      user_id INTEGER,

      wallet_name TEXT,

      wallet_type TEXT,

      balance REAL DEFAULT 0,

      currency_code TEXT NOT NULL DEFAULT 'USD',
      
      icon_code_point INTEGER,

      icon_font_family TEXT,

      created_at TEXT,

      updated_at TEXT,

      deleted_at TEXT,

      FOREIGN KEY(user_id)
      REFERENCES users(id)
      ON DELETE CASCADE
    )
  ''';
}
