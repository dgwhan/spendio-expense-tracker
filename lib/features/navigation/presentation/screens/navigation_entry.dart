// điểm vào của khu vực chính ứng dụng
// khởi tạo và cung cấp navigation state cho NavigationShell

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:spend_io_app/features/navigation/presentation/screens/navigation_shell.dart';

class NavigationEntry extends StatelessWidget {
  const NavigationEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: const NavigationShell(),
    );
  }
}
