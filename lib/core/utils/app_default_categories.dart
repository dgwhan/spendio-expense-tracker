class AppDefaultCategories {
  AppDefaultCategories._();

  static const List<String> expenseGroups = [
    'Living Expenses',
    'Variable Expenses',
    'Fixed Expenses',
  ];

  static const List<String> incomeGroups = [
    'Fixed Income',
    'Variable Income',
    'Other Income',
  ];

  /// Core data source synced 100% with AppColors hex properties
  static const List<Map<String, dynamic>> rawSeedData = [
    // === EXPENSE FLOW ===
    // Group: Living Expenses
    {
      'id': 'cat_market',
      'name': 'Market & Groceries',
      'type': 'expense',
      'group_name': 'Living Expenses',
      'icon_code_point': 57954,
      'color_value': 0xFF1565C0
    },
    {
      'id': 'cat_eating',
      'name': 'Food & Drinks',
      'type': 'expense',
      'group_name': 'Living Expenses',
      'icon_code_point': 57906,
      'color_value': 0xFFEF6C00
    },
    {
      'id': 'cat_transport',
      'name': 'Transportation',
      'type': 'expense',
      'group_name': 'Living Expenses',
      'icon_code_point': 58673,
      'color_value': 0xFF2E7D32
    },

    // Group: Variable Expenses
    {
      'id': 'cat_shopping',
      'name': 'Shopping',
      'type': 'expense',
      'group_name': 'Variable Expenses',
      'icon_code_point': 60168,
      'color_value': 0xFF6A1B9A
    },
    {
      'id': 'cat_entertainment',
      'name': 'Entertainment',
      'type': 'expense',
      'group_name': 'Variable Expenses',
      'icon_code_point': 58941,
      'color_value': 0xFF9C27B0
    },
    {
      'id': 'cat_beauty',
      'name': 'Beauty & Personal Care',
      'type': 'expense',
      'group_name': 'Variable Expenses',
      'icon_code_point': 59613,
      'color_value': 0xFFE91E63
    },
    {
      'id': 'cat_health',
      'name': 'Medical & Health',
      'type': 'expense',
      'group_name': 'Variable Expenses',
      'icon_code_point': 58732,
      'color_value': 0xFF06B6D4
    },
    {
      'id': 'cat_charity',
      'name': 'Charity & Donations',
      'type': 'expense',
      'group_name': 'Variable Expenses',
      'icon_code_point': 58665,
      'color_value': 0xFF10B981
    },

    // Group: Fixed Expenses
    {
      'id': 'cat_bills',
      'name': 'Bills & Utilities',
      'type': 'expense',
      'group_name': 'Fixed Expenses',
      'icon_code_point': 57903,
      'color_value': 0xFFC62828
    },
    {
      'id': 'cat_home',
      'name': 'Home & Rent',
      'type': 'expense',
      'group_name': 'Fixed Expenses',
      'icon_code_point': 58132,
      'color_value': 0xFF795548
    },
    {
      'id': 'cat_family',
      'name': 'Family & Relatives',
      'type': 'expense',
      'group_name': 'Fixed Expenses',
      'icon_code_point': 58379,
      'color_value': 0xFF4B5563
    },

    // === INCOME FLOW ===
    // Group: Fixed Income
    {
      'id': 'cat_salary',
      'name': 'Salary & Wages',
      'type': 'income',
      'group_name': 'Fixed Income',
      'icon_code_point': 57895,
      'color_value': 0xFF00695C
    },

    // Group: Variable Income
    {
      'id': 'cat_business',
      'name': 'Business',
      'type': 'income',
      'group_name': 'Variable Income',
      'icon_code_point': 58532,
      'color_value': 0xFF10B981
    },
    {
      'id': 'cat_profit',
      'name': 'Investment Profits',
      'type': 'income',
      'group_name': 'Variable Income',
      'icon_code_point': 57930,
      'color_value': 0xFF8B5CF6
    },
    {
      'id': 'cat_bonus',
      'name': 'Bonuses & Awards',
      'type': 'income',
      'group_name': 'Variable Income',
      'icon_code_point': 58425,
      'color_value': 0xFFF59E0B
    },
    {
      'id': 'cat_allowance',
      'name': 'Grants & Allowances',
      'type': 'income',
      'group_name': 'Variable Income',
      'icon_code_point': 58965,
      'color_value': 0xFFBA68C8
    },

    // Group: Other Income
    {
      'id': 'cat_debt_collection',
      'name': 'Debt Recovery',
      'type': 'income',
      'group_name': 'Other Income',
      'icon_code_point': 57892,
      'color_value': 0xFF06B6D4
    },
  ];
}
