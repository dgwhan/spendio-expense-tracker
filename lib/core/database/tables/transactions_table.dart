class TransactionsTable {
  static const tableName = 'transactions';

  static const createTable = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      user_id INTEGER NOT NULL,
      account_id TEXT NOT NULL,
      category_id TEXT NOT NULL,
      amount REAL NOT NULL,

      currency_code TEXT NOT NULL DEFAULT 'USD',

      type TEXT NOT NULL,
      
      note TEXT,
      transaction_date TEXT NOT NULL,
      created_at TEXT,
      updated_at TEXT,

      FOREIGN KEY(user_id)
      REFERENCES users(id)
      ON DELETE CASCADE,

      FOREIGN KEY(account_id)
      REFERENCES wallets(id)
      ON DELETE CASCADE,

      FOREIGN KEY(category_id)
      REFERENCES categories(id)
      ON DELETE CASCADE
    )
  ''';
}
