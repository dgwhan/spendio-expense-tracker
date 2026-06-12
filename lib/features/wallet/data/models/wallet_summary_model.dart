import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';

class WalletSummaryModel extends WalletSummaryEntity {
  const WalletSummaryModel({
    required super.totalAssets,
    required super.monthlyBudget,
    required super.totalSaved,
    required super.activeGoals,
  });

  //lưu dữ liệu vào sqflite/firebase
  Map<String, dynamic> toMap() {
    return {
      'total_assets': totalAssets,
      'monthly_budget': monthlyBudget,
      'total_saved': totalSaved,
      'active_goals': activeGoals,
    };
  }

  factory WalletSummaryModel.fromMap(Map<String, dynamic> map) {
    return WalletSummaryModel(
      totalAssets: (map['total_assets'] as num?)?.toDouble() ?? 0.0,
      monthlyBudget: (map['monthly_budget'] as num?)?.toDouble() ?? 0.0,
      totalSaved: (map['total_saved'] as num?)?.toDouble() ?? 0.0,
      activeGoals: map['active_goals'] as int? ?? 0,
    );
  }
}
