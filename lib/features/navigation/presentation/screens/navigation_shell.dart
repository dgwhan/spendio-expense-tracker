import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/home/presentation/screens/dashboard_screen.dart';
import 'package:spend_io_app/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:spend_io_app/features/navigation/presentation/widgets/bottom_navigation_bar.dart';
import 'package:spend_io_app/features/navigation/presentation/widgets/center_action_button.dart';

//Nguồn tham khảo ý tưởng cấu trúc:
/// YouTube Channel: Programming With FlexZ
/// (video: Flutter Persistent Bottom Navigation Bar, Nested Navigation and Routing in Flutter)
class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  //Khởi tạo 4 tab chính
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Tab 0: Home
    GlobalKey<NavigatorState>(), // Tab 1: Wallet
    GlobalKey<NavigatorState>(), // Tab 2: Insights
    GlobalKey<NavigatorState>(), // Tab 3: Profile
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;
    final provider = context.read<NavigationProvider>();

    return PopScope(
      canPop:
          false, //chặn thoát app khi ng dùng vuốt/hoặc nhấn nút quay lại vật lý trên điện thoại
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final NavigatorState? currentNavigator =
            _navigatorKeys[currentIndex].currentState;

        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop(); //Lùi trang nội bộ trong tab hiện tại
        } else {
          if (currentIndex != 0) {
            provider.changeTab(0);
          } else {
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
                navigatorKey: _navigatorKeys[0],
                rootPage: const DashboardScreen()),
            _buildTabWorkspace(
                navigatorKey: _navigatorKeys[1],
                rootPage: const Center(child: Text('Wallet Workspace'))),
            _buildTabWorkspace(
                navigatorKey: _navigatorKeys[2],
                rootPage: const Center(child: Text('Insights Workspace'))),
            _buildTabWorkspace(
                navigatorKey: _navigatorKeys[3],
                rootPage: const Center(child: Text('Profile Workspace'))),
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
                  //ấn 2 lần vào tab hiện tại thì sẽ quay lại main srceen của tab đó
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
                //TODO: gọi form nhập liệu khi ng dùng add transaction
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
