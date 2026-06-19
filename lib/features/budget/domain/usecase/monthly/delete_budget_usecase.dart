import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';

class DeleteBudgetUseCase {
  final BudgetRepository repository;

  DeleteBudgetUseCase(this.repository);

  Future<void> call({required int userId, required String budgetId}) async {
    await repository.deleteBudget(budgetId);
  }
}
