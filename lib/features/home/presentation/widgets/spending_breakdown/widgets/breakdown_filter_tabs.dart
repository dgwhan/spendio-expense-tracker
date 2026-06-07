import 'package:flutter/material.dart';
import 'package:spend_io_app/shared/components/app_segmented_control.dart';

class BreakdownFilterTabs extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const BreakdownFilterTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Week', 'Month', 'Year'];

    final currentIndex = tabs.indexOf(activeTab).clamp(0, tabs.length - 1);

    return AppSegmentedControl(
      tabs: tabs,
      currentIndex: currentIndex,
      onTabChanged: (index) {
        onTabChanged(tabs[index]);
      },
    );
  }
}
