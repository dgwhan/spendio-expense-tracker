import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/goal/domain/repositories/goal_repository.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:spend_io_app/features/wallet/domain/wallet_summary_result.dart';

class WalletRepositoryImpl implements WalletRepository {
  final AccountRepository accountRepository;
  final GoalRepository goalRepository;
  final BudgetRepository budgetRepository;

  WalletRepositoryImpl({
    required this.accountRepository,
    required this.goalRepository,
    required this.budgetRepository,
  });

  @override
  Future<WalletSummaryResult> getSummary(int localUserId) async {
    final accounts = await accountRepository.getAccounts(localUserId, '');
    final goals = await goalRepository.getGoals(localUserId);
    final budget = await budgetRepository.getCurrentBudget(localUserId);
    final categories = await budgetRepository.getBudgetCategories(localUserId);

    final activeAccounts = accounts.where((a) => a.deletedAt == null).toList();

    final totalAssets = activeAccounts.fold<double>(
      0,
      (sum, a) => sum + a.balance,
    );

    final totalSaved = goals.fold<double>(
      0,
      (sum, g) => sum + g.cachedCurrentAmount,
    );

    final summary = WalletSummaryEntity(
      totalAssets: totalAssets,
      monthlyBudget: budget?.amount ?? 0,
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
