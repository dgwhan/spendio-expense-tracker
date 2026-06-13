import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/auth/data/models/user_model.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import 'package:spend_io_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/screen/wallet_screen.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/create_account_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/update_account_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/delete_account_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/restore_account_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/add_goal_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_accounts_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_goals_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_categories_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/initialize_budget_categories_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class FakeWalletRepository implements WalletRepository {
  @override
  Future<List<AccountEntity>> getAccounts(int localUserId, String remoteUid, {bool forceSync = false}) async {
    return [
      AccountEntity(
        id: '1',
        userId: 1,
        name: 'Cash',
        type: AccountType.cash,
        balance: 1000000,
        icon: Icons.wallet,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
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
  Future<void> createAccount(int localUserId, String remoteUid, AccountEntity account) async {}
  @override
  Future<void> updateAccount(int localUserId, String remoteUid, AccountEntity account) async {}
  @override
  Future<void> deleteAccount(int localUserId, String remoteUid, String accountId) async {}
  @override
  Future<void> restoreAccount(int localUserId, String remoteUid, String accountId) async {}
  @override
  Future<void> saveGoal(int localUserId, String remoteUid, SavingGoalEntity goal) async {}
  @override
  Future<void> deleteGoal(String remoteUid, String goalId) async {}
  @override
  Future<void> syncWithFirebase(int localUserId, String remoteUid) async {}

  @override
  Future<List<BudgetCategoryEntity>> getCategories(int localUserId) async {
    return [];
  }
  @override
  Future<void> createCategory(int localUserId, BudgetCategoryEntity category) async {}
  @override
  Future<void> updateCategory(int localUserId, BudgetCategoryEntity category) async {}

  @override
  Future<bool> hasWalletData(int userId) async => false;
  @override
  Future<bool> hasAccounts(int userId) async => false;
  @override
  Future<bool> hasGoals(int userId) async => false;
  @override
  Future<bool> hasCategories(int userId) async => false;
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<bool> register(UserEntity user) async => true;
  @override
  Future<UserEntity?> login(String email, String password) async => null;
  @override
  Future<void> logout() async {}
  @override
  Future<bool> checkEmailExists(String email) async => false;
  @override
  Future<UserEntity?> getCurrentUser() async => null;
  @override
  Future<void> updateOnboarding({required UserEntity user}) async {}
  @override
  Future<bool> checkWalletExists(String email) async => false;
}

void main() {
  testWidgets('Test rendering WalletScreen', (WidgetTester tester) async {
    // Set a large screen size to prevent lazy-loaded slivers from being off-screen
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = FakeWalletRepository();
    final getWalletSummaryUseCase = GetWalletSummaryUseCase(repo);
    final getAccountsUseCase = GetAccountsUseCase(repo);
    final getGoalsUseCase = GetGoalsUseCase(repo);
    final createAccountUseCase = CreateAccountUseCase(repo);
    final updateAccountUseCase = UpdateAccountUseCase(repo);
    final deleteAccountUseCase = DeleteAccountUseCase(repo);
    final restoreAccountUseCase = RestoreAccountUseCase(repo);
    final getCategoriesUseCase = GetCategoriesUseCase(repo);
    final initializeBudgetCategoriesUseCase = InitializeBudgetCategoriesUseCase(repo);

    final viewModel = WalletViewModel(
      getWalletSummaryUseCase: getWalletSummaryUseCase,
      getAccountsUseCase: getAccountsUseCase,
      getGoalsUseCase: getGoalsUseCase,
      createAccountUseCase: createAccountUseCase,
      updateAccountUseCase: updateAccountUseCase,
      deleteAccountUseCase: deleteAccountUseCase,
      restoreAccountUseCase: restoreAccountUseCase,
      addGoalUseCase: AddGoalUseCase(repo),
      getCategoriesUseCase: getCategoriesUseCase,
      initializeBudgetCategoriesUseCase: initializeBudgetCategoriesUseCase,
    );

    final authRepo = FakeAuthRepository();
    final authProvider = AuthProvider(repository: authRepo);
    authProvider.currentUser = UserModel(
      id: 1,
      email: 'test@example.com',
      password: 'password',
      displayName: 'test',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<WalletViewModel>.value(value: viewModel),
          ],
          child: const WalletScreen(),
        ),
      ),
    );

    // Wait for all async database initialization flows to settle
    await tester.pumpAndSettle();

    // Expecting to find WalletHeader
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('My Accounts'), findsOneWidget);
  });
}
