class BudgetCategoriesTable {
  static const tableName = 'budget_categories';

  static const createTable = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,

      budget_id TEXT NOT NULL,

      category_id TEXT NOT NULL,

      amount REAL NOT NULL,

      created_at TEXT NOT NULL,

      updated_at TEXT NOT NULL,

      FOREIGN KEY (budget_id)
        REFERENCES budgets(id),

      FOREIGN KEY (category_id)
        REFERENCES categories(id)
    )
  ''';

  static const createIndexes = [
    '''
    CREATE INDEX IF NOT EXISTS idx_budget_categories_budget_id
    ON budget_categories(budget_id)
    ''',
    '''
    CREATE INDEX IF NOT EXISTS idx_budget_categories_category_id
    ON budget_categories(category_id)
    ''',
  ];
}
