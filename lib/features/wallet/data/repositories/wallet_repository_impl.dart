import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:spend_io_app/features/wallet/domain/wallet_summary_result.dart';

class WalletRepositoryImpl implements WalletRepository {
  final AccountRepository accountRepository;
  final SavingGoalRepository goalRepository;
  final BudgetRepository budgetRepository;

  WalletRepositoryImpl({
    required this.accountRepository,
    required this.goalRepository,
    required this.budgetRepository,
  });

  @override
  Future<WalletSummaryResult> getSummary(int localUserId,
      {String? preferredCurrencyCode}) async {
    final accounts = await accountRepository.getAccounts(localUserId, '');
    final goals = await goalRepository.getGoals(localUserId);
    final budget = await budgetRepository.getCurrentBudget(localUserId);
    final categories = await budgetRepository.getBudgetCategories(localUserId);

    final activeAccounts = accounts.where((a) => a.deletedAt == null).toList();

    double totalAssets = 0.0;
    for (var a in activeAccounts) {
      totalAssets += a.balance;
    }

    double totalSaved = 0.0;
    for (var g in goals) {
      totalSaved += g.cachedCurrentAmount;
    }

    final double monthlyBudget = budget?.amount ?? 0.0;

    final summary = WalletSummaryEntity(
      totalAssets: totalAssets,
      monthlyBudget: monthlyBudget,
      totalSaved: totalSaved,
      activeGoals: goals.length,
      remainingDays: 0,
    );

    return WalletSummaryResult(
      summary: summary,
      categories: categories
          .map(
            (e) => BudgetCategoryProgressEntity(
              budgetCategory: e,
              spent: 0,
              remaining: e.amount,
              percentage: 0,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<bool> hasWalletData(int userId) async {
    final accounts = await accountRepository.getAccounts(userId, '');
    final goals = await goalRepository.getGoals(userId);

    return accounts.isNotEmpty || goals.isNotEmpty;
  }
}
