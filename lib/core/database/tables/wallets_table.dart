class WalletsTable {
  static const tableName = 'wallets';

  static const createTable = '''
    CREATE TABLE wallets(
      id INTEGER PRIMARY KEY AUTOINCREMENT,

      user_id INTEGER,

      wallet_name TEXT,

      balance REAL DEFAULT 0,

      currency_code TEXT,

      created_at TEXT,

      FOREIGN KEY(user_id)
      REFERENCES users(id)
      ON DELETE CASCADE
    )
  ''';
}
