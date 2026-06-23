import 'package:flutter/material.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository profileRepository;
  bool _isLoading = false;

  UserEntity? _user;

  bool get isLoading => _isLoading;
  UserEntity? get user => _user;

  ProfileViewModel({required this.profileRepository});

  void updateUser(UserEntity? newUser) {
    _user = newUser;
    notifyListeners();
  }

  Future<bool> handleLogout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await profileRepository.logout();
      // await AppDatabase.close();

      _isLoading = false;
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi xử lý đăng xuất tại ProfileViewModel: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
