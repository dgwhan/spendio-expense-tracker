
class AppLocalizations {
  AppLocalizations._();

  static String _currentLanguage = 'en';
  static String get currentLanguage => _currentLanguage;

  static set currentLanguage(String value) {
    if (value == 'en' || value == 'vi') {
      _currentLanguage = value;
    }
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation & Header
      'home': 'Home',
      'wallet': 'Wallet',
      'insights': 'Insights',
      'profile': 'Profile',
      
      // Common
      'continue': 'Continue',
      'get_started': 'Get Started',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit',
      'unknown': 'Unknown',
      'not_set': 'Not set',
      'success': 'Success',
      'error': 'Error',
      'loading': 'Loading...',
      
      // Onboarding
      'onboarding_hello': 'Hello,\n{name}',
      'onboarding_manage_subtitle': 'Manage your finances smarter',
      'onboarding_occupation_title': 'What is your\noccupation?',
      'onboarding_goals_title': 'What are your\nfinancial goals?',
      'onboarding_currency_title': 'Choose your\npreferred currency',
      'onboarding_balance_title': 'Enter your\ninitial balance',
      'onboarding_balance_subtitle': 'Set up your cash/card wallet starting funds',
      'onboarding_input_placeholder': 'Type your answer here...',
      'onboarding_amount_placeholder': '0',
      
      // Home Screen
      'greeting_name': 'Good morning, {name}',
      'net_flow_balance': 'Net Flow Balance',
      'total_balance': 'Total Balance',
      'income': 'INCOME',
      'expense': 'EXPENSE',
      'savings': 'Savings',
      'recent_transactions': 'Recent Transactions',
      'view_all': 'View All',
      'see_more': 'See More',
      'see_less': 'See Less',
      'no_transactions': 'No recent transactions recorded',
      'financial_pulse': 'Financial Pulse',
      
      // Wallet Screen
      'total_assets': 'Total Assets',
      'accounts': 'Accounts',
      'limits': 'Limits',
      'add_account': 'Add Account',
      'edit_limit': 'Edit Limit',
      
      // Insights Screen
      'today': 'Today',
      'this_month': 'This Month',
      'this_year': 'This Year',
      'custom_range': 'Custom Range',
      'select_custom_range': 'Select Custom Range',
      'spending_details': 'Spending Details',
      'no_expenses_period': 'No expenses recorded for this period',
      'spending_trends': 'Spending Trends',
      
      // Profile Screen
      'financial_goal': 'Financial Goal',
      'currency': 'Currency',
      'occupation': 'Occupation',
      'general_settings': 'General Settings',
      'edit_profile': 'Edit Profile',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'sign_out': 'Sign Out',
      
      // Edit Profile Dialog/Sheet
      'edit_profile_title': 'Edit Profile Details',
      'full_name': 'Full Name',
      'profile_occupation_label': 'Occupation / Job',
      'profile_goal_label': 'Financial Goal / Budget',
      'update_success_msg': 'Profile updated successfully!',
      'update_fail_msg': 'Failed to update profile.',
    },
    'vi': {
      // Navigation & Header
      'home': 'Trang chủ',
      'wallet': 'Ví',
      'insights': 'Phân tích',
      'profile': 'Tài khoản',
      
      // Common
      'continue': 'Tiếp tục',
      'get_started': 'Bắt đầu',
      'cancel': 'Hủy',
      'save': 'Lưu',
      'edit': 'Sửa',
      'unknown': 'Không rõ',
      'not_set': 'Chưa cài đặt',
      'success': 'Thành công',
      'error': 'Lỗi',
      'loading': 'Đang tải...',
      
      // Onboarding
      'onboarding_hello': 'Xin chào,\n{name}',
      'onboarding_manage_subtitle': 'Quản lý tài chính thông minh hơn',
      'onboarding_occupation_title': 'Nghề nghiệp của bạn\nlà gì?',
      'onboarding_goals_title': 'Mục tiêu tài chính\ncủa bạn là gì?',
      'onboarding_currency_title': 'Chọn đơn vị\ntiền tệ mong muốn',
      'onboarding_balance_title': 'Nhập số dư\nban đầu của bạn',
      'onboarding_balance_subtitle': 'Thiết lập số tiền ban đầu cho các ví/thẻ',
      'onboarding_input_placeholder': 'Nhập câu trả lời ở đây...',
      'onboarding_amount_placeholder': '0',
      
      // Home Screen
      'greeting_name': 'Chào buổi sáng, {name}',
      'net_flow_balance': 'Số dư ròng',
      'total_balance': 'Tổng số dư',
      'income': 'THU NHẬP',
      'expense': 'CHI TIÊU',
      'savings': 'Tiết kiệm',
      'recent_transactions': 'Giao dịch gần đây',
      'view_all': 'Xem tất cả',
      'see_more': 'Xem thêm',
      'see_less': 'Thu gọn',
      'no_transactions': 'Chưa ghi nhận giao dịch nào',
      'financial_pulse': 'Mạch tài chính',
      
      // Wallet Screen
      'total_assets': 'Tổng tài sản',
      'accounts': 'Tài khoản',
      'limits': 'Hạn mức chi tiêu',
      'add_account': 'Thêm tài khoản',
      'edit_limit': 'Sửa hạn mức',
      
      // Insights Screen
      'today': 'Hôm nay',
      'this_month': 'Tháng này',
      'this_year': 'Năm nay',
      'custom_range': 'Tùy chỉnh',
      'select_custom_range': 'Chọn khoảng thời gian',
      'spending_details': 'Chi tiết chi tiêu',
      'no_expenses_period': 'Không có chi tiêu trong khoảng thời gian này',
      'spending_trends': 'Xu hướng chi tiêu',
      
      // Profile Screen
      'financial_goal': 'Mục tiêu tài chính',
      'currency': 'Tiền tệ',
      'occupation': 'Nghề nghiệp',
      'general_settings': 'Cài đặt chung',
      'edit_profile': 'Chỉnh sửa tài khoản',
      'language': 'Ngôn ngữ',
      'dark_mode': 'Chế độ tối',
      'sign_out': 'Đăng xuất',
      
      // Edit Profile Dialog/Sheet
      'edit_profile_title': 'Chỉnh sửa thông tin',
      'full_name': 'Họ và tên',
      'profile_occupation_label': 'Công việc / Nghề nghiệp',
      'profile_goal_label': 'Mục tiêu tài chính / Ngân sách',
      'update_success_msg': 'Cập nhật tài khoản thành công!',
      'update_fail_msg': 'Cập nhật tài khoản thất bại.',
    }
  };

  static String translate(String key, {Map<String, String>? args}) {
    String value = _localizedValues[_currentLanguage]?[key] ?? _localizedValues['en']?[key] ?? key;
    if (args != null) {
      args.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }
}
