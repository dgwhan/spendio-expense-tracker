class BudgetCategoriesTable {
  static const tableName = 'budget_categories';

  static const createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,

      user_id INTEGER NOT NULL,

      category_id TEXT NOT NULL,

      amount REAL NOT NULL,

      period_type TEXT NOT NULL,

      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,

      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,

      FOREIGN KEY (category_id)
        REFERENCES categories(id)
    )
  ''';

  static const createIndexes = [
    '''
    CREATE INDEX idx_budget_categories_user_id
    ON budget_categories(user_id);
    ''',
    '''
    CREATE INDEX idx_budget_categories_category_id
    ON budget_categories(category_id);
    ''',
    '''
    CREATE INDEX idx_budget_categories_period
    ON budget_categories(start_date,end_date);
    '''
  ];
}
