import 'package:flutter/material.dart';
import 'package:spend_io_app/core/services/database_service.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.init();

  runApp(const SpendIOApp());
}