import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/data/datasource/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/financial_health_status.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';

class WalletViewmodel extends ChangeNotifier {
  WalletSummaryEntity summary = WalletLocalDataSource.summary;

  List<BudgetCategoryEntity> categories = WalletLocalDataSource.categories;
  List<AccountEntity> get accounts => WalletLocalDataSource.accounts;
  List<SavingGoalEntity> get goals => WalletLocalDataSource.goals;

  DateTime selectedMonth = DateTime.now();

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

  //financial health caculation
  FinancialHealthStatus get healthStatus {
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

  // changes selected month
  void selectMonth(DateTime month) {
    selectedMonth = month;
    notifyListeners();
  }
}
