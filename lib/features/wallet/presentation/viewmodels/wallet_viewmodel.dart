import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart'; // CHÍNH XÁC: Import đúng Progress từ Budget feature
import 'package:spend_io_app/features/wallet/domain/entities/financial_health_status.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/goals/get_goals_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/goals/add_goal_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart'; // ĐỂ LẤY PROGRESS THỰC TẾ
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';

class WalletViewModel extends ChangeNotifier {
  final GetWalletSummaryUseCase getWalletSummaryUseCase;
  final GetGoalsUseCase getGoalsUseCase;
  final AddGoalUseCase addGoalUseCase;
  final BudgetRepository budgetRepository; // Thay thế usecase category cũ
  final BudgetProgressCalculator
      budgetCalculator; // Inject engine tính toán realtime

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  int _requestId = 0;
  bool _disposed = false;

  WalletSummaryEntity _summary = const WalletSummaryEntity(
    totalAssets: 0.0,
    monthlyBudget: 0.0,
    totalSaved: 0.0,
    activeGoals: 0,
  );
  List<SavingGoalEntity> _goals = [];

  List<BudgetCategoryProgressEntity> _categoriesProgress = [];
  DateTime selectedMonth = DateTime.now();

  WalletViewModel({
    required this.getWalletSummaryUseCase,
    required this.getGoalsUseCase,
    required this.addGoalUseCase,
    required this.budgetRepository,
    required this.budgetCalculator,
  });

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WalletSummaryEntity get summary => _summary;
  List<SavingGoalEntity> get goals => _goals;
  List<BudgetCategoryProgressEntity> get categoriesProgress =>
      _categoriesProgress;
  UserEntity? get currentUser => _currentUser;
  String get remoteUid => _remoteUid;

  void updateUser(UserEntity? user) {
    if (_isLoading || _disposed) return;

    final hasChanged =
        _currentUser?.id != user?.id || _currentUser?.email != user?.email;
    if (!hasChanged && (_goals.isNotEmpty || _summary.totalAssets > 0)) return;

    _currentUser = user;

    if (_currentUser != null) {
      Future.microtask(() => initialize());
    }
  }

  String get currentMonthLabel => DateFormat('MMMM yyyy').format(selectedMonth);
  String get budgetStatus => '$currentMonthLabel Budget';

  Future<void> initialize() async {
    final int request = ++_requestId;
    final isFirstLoad = _goals.isEmpty && _summary.totalAssets == 0;

    if (isFirstLoad) {
      _isLoading = true;
      _errorMessage = null;
      _safeNotify();
    }

    try {
      if (_currentUser != null) {
        final localId = _currentUser!.id ?? 1;

        //Tải dữ liệu Offline cục bộ
        _summary = await getWalletSummaryUseCase(localId);
        _goals = await getGoalsUseCase(localId, _remoteUid);

        //Bóc tách hạn mức tháng và tính toán phần tiến độ thực tế thông qua Calculator tập trung
        final currentBudget = await budgetRepository.getCurrentBudget(localId);
        if (currentBudget != null && request == _requestId && !_disposed) {
          _categoriesProgress =
              await budgetCalculator.calculateCategoryProgressList(
            budgetId: currentBudget.id,
            startDate: currentBudget.startDate,
            endDate: currentBudget.endDate,
          );
        }

        if (_disposed || request != _requestId) return;
        _isLoading = false;
        _safeNotify();

        //Silent Sync ngầm với Firebase
        final rUid = _remoteUid;
        if (rUid.isNotEmpty) {
          await getWalletSummaryUseCase.repository
              .syncWithFirebase(localId, rUid);

          if (_disposed || request != _requestId) return;

          //Nạp lại dữ liệu sạch sau khi sync
          _summary = await getWalletSummaryUseCase(localId);
          _goals = await getGoalsUseCase(localId, _remoteUid);

          final syncBudget = await budgetRepository.getCurrentBudget(localId);
          if (syncBudget != null && request == _requestId && !_disposed) {
            _categoriesProgress =
                await budgetCalculator.calculateCategoryProgressList(
              budgetId: syncBudget.id,
              startDate: syncBudget.startDate,
              endDate: syncBudget.endDate,
            );
          }

          _safeNotify();
        }
      } else {
        _resetStates();
      }
    } catch (e) {
      if (request == _requestId) {
        _errorMessage = e.toString();
        _isLoading = false;
        _safeNotify();
      }
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
    _categoriesProgress = [];
    _isLoading = false;
    _safeNotify();
  }

  String get _remoteUid {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> fetchWalletSummary() async {
    if (_currentUser == null) return;
    _summary = await getWalletSummaryUseCase(_currentUser!.id ?? 1);
    _safeNotify();
  }

  Future<void> addNewGoal(SavingGoalEntity goal) async {
    if (_currentUser == null) return;
    final localId = _currentUser!.id ?? 1;
    final rUid = _remoteUid;

    _isLoading = true;
    _safeNotify();

    try {
      await addGoalUseCase(localId, rUid, goal);
      await initialize();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _safeNotify();
    }
  }

  void selectMonth(DateTime month) {
    selectedMonth = month;
    initialize();
  }

  double get totalSpent {
    return _categoriesProgress.fold(0.0, (sum, item) => sum + item.spent);
  }

  double get totalBudget => summary.monthlyBudget;

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

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
