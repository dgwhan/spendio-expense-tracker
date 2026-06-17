import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/financial_health_status.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/goals/get_goals_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/goals/add_goal_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_categories_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/initialize_budget_categories_usecase.dart';

class WalletViewModel extends ChangeNotifier {
  final GetWalletSummaryUseCase getWalletSummaryUseCase;
  final GetGoalsUseCase getGoalsUseCase;
  final AddGoalUseCase addGoalUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final InitializeBudgetCategoriesUseCase initializeBudgetCategoriesUseCase;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  WalletSummaryEntity _summary = const WalletSummaryEntity(
    totalAssets: 0.0,
    monthlyBudget: 0.0,
    totalSaved: 0.0,
    activeGoals: 0,
  );
  List<SavingGoalEntity> _goals = [];
  List<BudgetCategoryEntity> _categories = [];
  DateTime selectedMonth = DateTime.now();

  WalletViewModel({
    required this.getWalletSummaryUseCase,
    required this.getGoalsUseCase,
    required this.addGoalUseCase,
    required this.getCategoriesUseCase,
    required this.initializeBudgetCategoriesUseCase,
  });

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WalletSummaryEntity get summary => _summary;
  List<SavingGoalEntity> get goals => _goals;
  List<BudgetCategoryEntity> get categories => _categories;
  UserEntity? get currentUser => _currentUser;
  String get remoteUid => _remoteUid;

  void updateUser(UserEntity? user) {
    if (_isLoading) return;

    final hasChanged =
        _currentUser?.id != user?.id || _currentUser?.email != user?.email;

    // Nếu thông tin user không đổi và RAM đã có sẵn dữ liệu thì đứng im, không tự ý nạp lại gây rollback
    if (!hasChanged && (_goals.isNotEmpty || _summary.totalAssets > 0)) return;

    _currentUser = user;

    // if (_currentUser != null) {
    //   Future.microtask(() => initialize());
    // }
  }

  String get currentMonthLabel {
    return DateFormat('MMMM yyyy').format(selectedMonth);
  }

  String get budgetStatus {
    return '$currentMonthLabel Budget';
  }

  // 🔥 ĐÃ FIX HOÀN TOÀN: Luồng Khởi tạo hỗ trợ Silent Refresh bảo vệ trạng thái RAM
  Future<void> initialize() async {
    // Chỉ bật loading xoay tròn nếu là lần đầu tiên nạp (chưa có dữ liệu), tránh làm UI bị giật về 0
    final isFirstLoad = _goals.isEmpty && _summary.totalAssets == 0;

    if (isFirstLoad) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      if (_currentUser != null) {
        final localId = _currentUser!.id ?? 1;

        // 1. Tải toàn bộ dữ liệu offline từ Local DB lên trước để hiển thị tức thì
        await initializeCategories(localId);
        await loadSummary(localId);
        await loadGoals(localId);
        await loadCategories(localId);

        // Sau khi data local đã sẵn sàng trên RAM, tắt loading ngay để UI hiển thị mượt mà
        _isLoading = false;
        notifyListeners();

        // 2. Tiến hành đồng bộ ngầm (Silent Sync) với Firebase mà không block UI
        final rUid = _remoteUid;
        if (rUid.isNotEmpty) {
          await getWalletSummaryUseCase.repository
              .syncWithFirebase(localId, rUid);

          // Sau khi sync xong, nạp đè dữ liệu mới nhất từ DB vật lý lên RAM
          await loadSummary(localId);
          await loadGoals(localId);
          await loadCategories(localId);
          notifyListeners();
        }
      } else {
        _resetStates();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resetStates() {
    _summary = const WalletSummaryEntity(
      totalAssets: 0.0,
      monthlyBudget: 0.0,
      totalSaved: 0.0,
      activeGoals: 0,
    );
    _goals = [];
    _categories = [];
    _isLoading = false;
    notifyListeners();
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

  Future<void> loadGoals(int localId) async {
    _goals = await getGoalsUseCase(localId, _remoteUid);
  }

  Future<void> loadCategories(int localId) async {
    _categories = await getCategoriesUseCase(localId);
  }

  Future<void> fetchWalletSummary() async {
    if (_currentUser == null) return;
    await loadSummary(_currentUser!.id ?? 1);
    notifyListeners();
  }

  Future<void> addNewGoal(SavingGoalEntity goal) async {
    if (_currentUser == null) return;
    final localId = _currentUser!.id ?? 1;
    final rUid = _remoteUid;

    _isLoading = true;
    notifyListeners();

    try {
      await addGoalUseCase(localId, rUid, goal);
      await initialize();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectMonth(DateTime month) {
    selectedMonth = month;
    initialize();
  }

  double get totalSpent {
    return categories.fold(0.0, (sum, item) => sum + item.spent);
  }

  double get totalBudget {
    return summary.monthlyBudget;
  }

  int get daysLeft {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.difference(now).inDays;
  }

  FinancialHealthStatus get healthStatus {
    if (summary.totalAssets < 0) return FinancialHealthStatus.critical;
    if (summary.totalAssets > 0 &&
        summary.totalSaved == 0 &&
        summary.monthlyBudget == 0) {
      return FinancialHealthStatus.good;
    }
    if (summary.totalAssets == 0) return FinancialHealthStatus.good;

    final ratio = summary.totalSaved / summary.totalAssets;
    if (ratio >= 0.40) return FinancialHealthStatus.excellent;
    if (ratio >= 0.25) return FinancialHealthStatus.good;
    if (ratio >= 0.10) return FinancialHealthStatus.warning;
    return FinancialHealthStatus.critical;
  }
}
