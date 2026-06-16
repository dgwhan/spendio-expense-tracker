import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/home/presentation/screens/home_screen.dart';
import 'package:spend_io_app/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:spend_io_app/features/navigation/presentation/widgets/bottom_navigation_bar.dart';
import 'package:spend_io_app/features/navigation/presentation/widgets/center_action_button.dart';
import 'package:spend_io_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:spend_io_app/features/wallet/presentation/screen/wallet_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/add_transaction_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _openAddTransactionFlow(BuildContext context) {
    final int currentUserId =
        context.read<AuthProvider>().currentUser?.toEntity().id ?? 1;
    final accountVM = context.read<AccountViewModel>();
    final txViewModel = context.read<TransactionViewModel>();

    final String activeAccountId =
        accountVM.accounts.isNotEmpty ? accountVM.accounts.first.id : '';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (pageContext) =>
            ChangeNotifierProvider<TransactionViewModel>.value(
          value: txViewModel,
          child: AddTransactionScreen(
            accountId: activeAccountId,
            userId: currentUserId,
            transactionVM: txViewModel,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;
    final provider = context.read<NavigationProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final NavigatorState? currentNavigator =
            _navigatorKeys[currentIndex].currentState;

        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else {
          if (currentIndex != 0) {
            provider.changeTab(0);
          } else if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: currentIndex,
          children: [
            _buildTabWorkspace(
                navigatorKey: _navigatorKeys[0], rootPage: const HomeScreen()),
            _buildTabWorkspace(
                navigatorKey: _navigatorKeys[1],
                rootPage: const WalletScreen()),
            _buildTabWorkspace(
                navigatorKey: _navigatorKeys[2],
                rootPage: const Center(child: Text('Insights Workspace'))),
            _buildTabWorkspace(
                navigatorKey: _navigatorKeys[3],
                rootPage: const ProfileScreen()),
          ],
        ),
        bottomNavigationBar: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            AppBottomNavigationBar(
              currentIndex: currentIndex,
              onTabSelected: (index) {
                if (currentIndex == index) {
                  _navigatorKeys[index]
                      .currentState
                      ?.popUntil((route) => route.isFirst);
                } else {
                  provider.changeTab(index);
                }
              },
            ),
            Positioned(
              top: -24,
              child: CenterActionButton(onPressed: () {
                _openAddTransactionFlow(context);
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabWorkspace({
    required GlobalKey<NavigatorState> navigatorKey,
    required Widget rootPage,
  }) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => rootPage);
      },
    );
  }
}
