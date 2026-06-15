import 'package:flutter/material.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository profileRepository;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProfileViewModel({required this.profileRepository});

  Future<bool> handleLogout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await profileRepository.logout();
      _isLoading = false;
      notifyListeners();
      return true; 
    } catch (e) {
      debugPrint('Lỗi xử lý đăng xuất tại ProfileViewModel: $e');
      _isLoading = false;
      notifyListeners();
      return false; // Thất bại
    }
  }
}
