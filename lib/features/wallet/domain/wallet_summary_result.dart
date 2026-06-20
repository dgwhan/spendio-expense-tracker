import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';

class WalletSummaryResult {
  final WalletSummaryEntity summary;
  final List<BudgetCategoryProgressEntity> categories;

  const WalletSummaryResult({
    required this.summary,
    required this.categories,
  });
}
