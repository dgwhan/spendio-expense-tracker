import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/financial_health_status.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/screen/wallet_screen.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/add_account_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/add_goal_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_accounts_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_goals_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class FakeWalletRepository implements WalletRepository {
  @override
  Future<List<AccountEntity>> getAccounts(int localUserId, String remoteUid, {bool forceSync = false}) async {
    return [
      const AccountEntity(id: '1', name: 'Cash', type: AccountType.cash, balance: 1000000, icon: Icons.wallet),
    ];
  }
  @override
  Future<List<SavingGoalEntity>> getGoals(int localUserId, String remoteUid, {bool forceSync = false}) async {
    return [];
  }
  @override
  Future<WalletSummaryEntity> getSummary(int localUserId) async {
    return const WalletSummaryEntity(totalAssets: 1000000, monthlyBudget: 500000, totalSaved: 0, activeGoals: 0);
  }
  @override
  Future<void> saveAccount(int localUserId, String remoteUid, AccountEntity account) async {}
  @override
  Future<void> saveGoal(int localUserId, String remoteUid, SavingGoalEntity goal) async {}
  @override
  Future<void> deleteAccount(String remoteUid, String accountId) async {}
  @override
  Future<void> deleteGoal(String remoteUid, String goalId) async {}
  @override
  Future<void> syncWithFirebase(int localUserId, String remoteUid) async {}
}

void main() {
  testWidgets('Test rendering WalletScreen', (WidgetTester tester) async {
    final repo = FakeWalletRepository();
    final getWalletSummaryUseCase = GetWalletSummaryUseCase(repo);
    final getAccountsUseCase = GetAccountsUseCase(repo);
    final getGoalsUseCase = GetGoalsUseCase(repo);
    final addAccountUseCase = AddAccountUseCase(repo);
    final addGoalUseCase = AddGoalUseCase(repo);

    final viewModel = WalletViewModel(
      getWalletSummaryUseCase: getWalletSummaryUseCase,
      getAccountsUseCase: getAccountsUseCase,
      getGoalsUseCase: getGoalsUseCase,
      addAccountUseCase: addAccountUseCase,
      addGoalUseCase: addGoalUseCase,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<WalletViewModel>.value(
          value: viewModel,
          child: const WalletScreen(),
        ),
      ),
    );

    // Trigger frame
    await tester.pump();

    // Expecting to find WalletHeader
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('My Accounts'), findsOneWidget);
  });
}
