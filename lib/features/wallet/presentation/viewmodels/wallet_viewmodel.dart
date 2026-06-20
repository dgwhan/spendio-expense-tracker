import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';

class WalletViewModel extends ChangeNotifier {
  final GetWalletSummaryUseCase getWalletSummaryUseCase;

  WalletViewModel({
    required this.getWalletSummaryUseCase,
  });

  WalletSummaryEntity _summary = WalletSummaryEntity.empty;
  WalletSummaryEntity get summary => _summary;

  List<BudgetCategoryProgressEntity> _categories = [];
  List<BudgetCategoryProgressEntity> get categories => _categories;

  bool _loading = false;
  bool get isLoading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserEntity? _user;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  // =========================
  // DERIVED STATE (KHÔNG STORE)
  // =========================
  int get daysLeft => _summary.remainingDays;

  double get totalSpent => _summary.totalAssets;
  double get totalBudget => _summary.monthlyBudget;

  Future<void> initialize() async {
    if (_user == null) return;

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await getWalletSummaryUseCase(_user!.id!);

      _summary = result.summary;
      _categories = result.categories;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void updateUser(UserEntity? user) {
    if (_user?.id == user?.id) return;
    _user = user;

    if (user != null) {
      initialize();
    }
  }

  void selectMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  Future<void> refreshBudgetProgress() async {
    if (_user == null) return;
    await initialize();
  }
}
