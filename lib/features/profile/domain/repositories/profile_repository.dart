import 'package:spend_io_app/features/profile/data/models/profile_user_model.dart';

abstract class ProfileRepository {
  Future<ProfileUserEntity?> getCurrentUser();
  Future<void> logout();
}
