import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/financial_health_status.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/add_account_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/add_goal_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_accounts_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_goals_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_categories_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/initialize_budget_categories_usecase.dart';

class WalletViewModel extends ChangeNotifier {
  final GetWalletSummaryUseCase getWalletSummaryUseCase;
  final GetAccountsUseCase getAccountsUseCase;
  final GetGoalsUseCase getGoalsUseCase;
  final AddAccountUseCase addAccountUseCase;
  final AddGoalUseCase addGoalUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final InitializeBudgetCategoriesUseCase initializeBudgetCategoriesUseCase;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  int? _lastUserId;

  WalletSummaryEntity _summary = const WalletSummaryEntity(
    totalAssets: 0.0,
    monthlyBudget: 0.0,
    totalSaved: 0.0,
    activeGoals: 0,
  );
  List<AccountEntity> _accounts = [];
  List<SavingGoalEntity> _goals = [];
  List<BudgetCategoryEntity> _categories = [];
  DateTime selectedMonth = DateTime.now();

  WalletViewModel({
    required this.getWalletSummaryUseCase,
    required this.getAccountsUseCase,
    required this.getGoalsUseCase,
    required this.addAccountUseCase,
    required this.addGoalUseCase,
    required this.getCategoriesUseCase,
    required this.initializeBudgetCategoriesUseCase,
  }) {
    _accounts = [];
    _goals = [];
    _categories = [];
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WalletSummaryEntity get summary => _summary;
  List<AccountEntity> get accounts => _accounts;
  List<SavingGoalEntity> get goals => _goals;
  List<BudgetCategoryEntity> get categories => _categories;

  /// Cập nhật thông tin User hiện tại từ AuthProvider
  void updateUser(UserEntity? user) {
    // Guard: avoid scheduling fetch when already loading
    if (_isLoading) return;

    final hasChanged = _currentUser?.id != user?.id ||
        _currentUser?.email != user?.email ||
        _currentUser?.onboardingCompleted != user?.onboardingCompleted ||
        _currentUser?.currency != user?.currency;

    final newUserId = user?.id;
    if (!hasChanged) return;

    // Additional guard: avoid redundant fetch for same user id
    if (newUserId != null && _lastUserId == newUserId) return;

    _currentUser = user;
    _lastUserId = newUserId;

    Future.microtask(() => initialize());
  }

  /// Định dạng hiển thị tháng/năm hiện tại
  String get currentMonthLabel {
    return DateFormat('MMMM yyyy').format(selectedMonth);
  }

  /// Định dạng tiêu đề chu kỳ ngân sách
  String get budgetStatus {
    return '$currentMonthLabel Budget';
  }

  /// Tải dữ liệu ví thực tế từ database qua chu trình initialize()
  Future<void> initialize() async {
    final sw = Stopwatch()..start();
    debugPrint(
        'WalletViewModel.initialize: start userId=${_currentUser?.id}');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUser != null) {
        final localId = _currentUser!.id ?? 1;
        await initializeCategories(localId);
        await loadSummary(localId);
        await loadAccounts(localId);
        await loadGoals(localId);
        await loadCategories(localId);
      } else {
        _summary = const WalletSummaryEntity(
          totalAssets: 0.0,
          monthlyBudget: 0.0,
          totalSaved: 0.0,
          activeGoals: 0,
        );
        _accounts = [];
        _goals = [];
        _categories = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('WalletViewModel.initialize: error: $e');
    } finally {
      _isLoading = false;
      sw.stop();
      debugPrint(
          'WalletViewModel.initialize: finished in ${sw.elapsedMilliseconds}ms');
      notifyListeners();
    }
  }

  String get _remoteUid {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> initializeCategories(int localId) async {
    await initializeBudgetCategoriesUseCase(localId);
  }

  Future<void> loadSummary(int localId) async {
    _summary = await getWalletSummaryUseCase(localId);
  }

  Future<void> loadAccounts(int localId) async {
    _accounts = await getAccountsUseCase(localId, _remoteUid);
  }

  Future<void> loadGoals(int localId) async {
    _goals = await getGoalsUseCase(localId, _remoteUid);
  }

  Future<void> loadCategories(int localId) async {
    _categories = await getCategoriesUseCase(localId);
  }

  /// Backward compatible trigger method
  Future<void> fetchWalletData() async {
    await initialize();
  }

  Future<void> fetchWalletSummary() async {
    await initialize();
  }

  /// Thêm ví tài khoản mới
  Future<void> addNewAccount(AccountEntity account) async {
    if (_currentUser == null) return;
    final localId = _currentUser!.id ?? 1;
    final remoteUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    _isLoading = true;
    notifyListeners();

    try {
      await addAccountUseCase(localId, remoteUid, account);
      await initialize();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thêm mục tiêu tiết kiệm mới
  Future<void> addNewGoal(SavingGoalEntity goal) async {
    if (_currentUser == null) return;
    final localId = _currentUser!.id ?? 1;
    final remoteUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    _isLoading = true;
    notifyListeners();

    try {
      await addGoalUseCase(localId, remoteUid, goal);
      await initialize();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thay đổi tháng được chọn và tự động refresh lại dữ liệu
  void selectMonth(DateTime month) {
    selectedMonth = month;
    fetchWalletSummary();
  }

  /// Tính tổng số tiền đã chi tiêu động từ danh sách Entity dùng chung
  double get totalSpent {
    return categories.fold(0.0, (sum, item) => sum + item.spent);
  }

  /// Lấy hạn mức ngân sách tổng của chu kỳ tháng hiện tại
  double get totalBudget {
    return summary.monthlyBudget;
  }

  /// Tính toán số ngày thực tế còn lại trong tháng
  int get daysLeft {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.difference(now).inDays;
  }

  // Tính toán sức khỏe tài chính dựa trên tỷ lệ tích lũy
  //
  // Công thức: Tổng tích lũy (Goals) / Tổng tài sản (Assets)
  // Ý nghĩa: Đánh giá tỷ lệ phần trăm tài sản được phân bổ cho mục tiêu dài hạn.
  //
  // Phân bậc điều kiện:
  // >= 0.40: Xuất sắc (Excellent) -> Tích lũy ở mức lý tưởng.
  // >= 0.25: Tốt (Good)          -> Đạt chuẩn quản lý tài chính lành mạnh.
  // >= 0.10: Cảnh báo (Warning)  -> Tích lũy thấp, cần tối ưu lại chi tiêu.
  // < 0.10 : Nguy kịch (Critical)
  FinancialHealthStatus get healthStatus {
    if (summary.totalAssets < 0) {
      return FinancialHealthStatus.critical;
    }

    //set mặc định cho user mới
    if (summary.totalAssets > 0 &&
        summary.totalSaved == 0 &&
        summary.monthlyBudget == 0) {
      return FinancialHealthStatus.good;
    }

    //nếu tài sản bằng 0 tròn trĩnh
    if (summary.totalAssets == 0) {
      return FinancialHealthStatus.good;
    }

    //luồng tính toán tỷ lệ khi đã có dữ liệu tích lũy
    final ratio = summary.totalSaved / summary.totalAssets;

    if (ratio >= 0.40) {
      return FinancialHealthStatus.excellent;
    }
    if (ratio >= 0.25) {
      return FinancialHealthStatus.good;
    }
    if (ratio >= 0.10) {
      return FinancialHealthStatus.warning;
    }

    return FinancialHealthStatus.critical;
  }
}
