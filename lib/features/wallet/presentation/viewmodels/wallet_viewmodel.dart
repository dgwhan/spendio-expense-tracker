import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/features/auth/data/models/user_model.dart';
import 'package:spend_io_app/features/wallet/data/datasource/wallet_local_data_source.dart';
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

class WalletViewModel extends ChangeNotifier {
  final GetWalletSummaryUseCase getWalletSummaryUseCase;
  final GetAccountsUseCase getAccountsUseCase;
  final GetGoalsUseCase getGoalsUseCase;
  final AddAccountUseCase addAccountUseCase;
  final AddGoalUseCase addGoalUseCase;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  WalletSummaryEntity _summary = WalletLocalDataSource.summary;
  List<AccountEntity> _accounts = [];
  List<SavingGoalEntity> _goals = [];
  DateTime selectedMonth = DateTime.now();

  WalletViewModel({
    required this.getWalletSummaryUseCase,
    required this.getAccountsUseCase,
    required this.getGoalsUseCase,
    required this.addAccountUseCase,
    required this.addGoalUseCase,
  }) {
    // Tải dữ liệu mặc định (mock) khi bắt đầu
    _accounts = List.from(WalletLocalDataSource.accounts);
    _goals = List.from(WalletLocalDataSource.goals);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WalletSummaryEntity get summary => _summary;
  List<AccountEntity> get accounts => _accounts;
  List<SavingGoalEntity> get goals => _goals;
  List<BudgetCategoryEntity> get categories => WalletLocalDataSource.categories;

  /// Cập nhật thông tin User hiện tại từ AuthProvider
  void updateUser(UserModel? user) {
    if (_currentUser?.id != user?.id || _currentUser?.email != user?.email) {
      _currentUser = user;
      fetchWalletData();
    }
  }

  /// Định dạng hiển thị tháng/năm hiện tại
  String get currentMonthLabel {
    return DateFormat('MMMM yyyy').format(selectedMonth);
  }

  /// Định dạng tiêu đề chu kỳ ngân sách
  String get budgetStatus {
    return '$currentMonthLabel Budget';
  }

  /// Tải dữ liệu ví thực tế từ database
  Future<void> fetchWalletData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUser != null) {
        final localId = _currentUser!.id ?? 1;
        final remoteUid = FirebaseAuth.instance.currentUser?.uid ?? '';

        // Tải bất đồng bộ các dữ liệu
        _accounts = await getAccountsUseCase(localId, remoteUid);
        _goals = await getGoalsUseCase(localId, remoteUid);
        _summary = await getWalletSummaryUseCase(localId);
      } else {
        // Fallback sang dữ liệu mock nếu chưa đăng nhập
        _summary = WalletLocalDataSource.summary;
        _accounts = List.from(WalletLocalDataSource.accounts);
        _goals = List.from(WalletLocalDataSource.goals);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWalletSummary() async {
    await fetchWalletData();
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
      await fetchWalletData();
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
      await fetchWalletData();
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

  /// Tính toán sức khỏe tài chính dựa trên tỷ lệ tích lũy
  FinancialHealthStatus get healthStatus {
    if (summary.totalAssets == 0) return FinancialHealthStatus.warning;

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
