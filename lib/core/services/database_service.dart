import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:spend_io_app/features/auth/data/models/user_model.dart';

class DatabaseService {
  DatabaseService._();

  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [
        UserModelSchema,
      ],
      directory: dir.path
    );
  }
}