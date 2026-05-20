import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String email;
  late String password;

  DateTime createdAt = DateTime.now();
}
