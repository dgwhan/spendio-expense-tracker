import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:spend_io_app/features/onboarding/domain/usecases/check_onboarding_usecase.dart';
import 'package:spend_io_app/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:spend_io_app/features/onboarding/domain/usecases/get_onboarding_usecase.dart';
import 'package:spend_io_app/features/onboarding/domain/usecases/save_onboarding_usecase.dart';

class OnboardingViewModel extends ChangeNotifier {
  final SaveOnboardingUseCase saveOnboardingUseCase;
  final GetOnboardingUseCase getOnboardingUseCase;
  final CheckOnboardingUseCase checkOnboardingUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingViewModel({
    required this.saveOnboardingUseCase,
    required this.getOnboardingUseCase,
    required this.checkOnboardingUseCase,
    required this.completeOnboardingUseCase,
  });

  // TÍNH NĂNG MỚI: Quản lý luồng phát tín hiệu rung lắc
  final StreamController<bool> _shakeController =
      StreamController<bool>.broadcast();
  Stream<bool> get shakeStream => _shakeController.stream;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _displayName;
  String? get displayName => _displayName;

  String? _occupation;
  String? get occupation => _occupation;

  final List<String> _goals = [];
  List<String> get goals => _goals;

  String? _currencyCode;
  String? get currencyCode => _currencyCode;

  double? _initialBalance;
  double? get initialBalance => _initialBalance;

  // TÍNH NĂNG MỚI: Hàm trigger phát tín hiệu rung cho các card nhỏ lắng nghe
  void triggerShake() {
    _shakeController.add(true);
  }

  void nextStep() {
    _currentStep++;
    _hasError = false;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep == 0) return;
    _currentStep--;
    _hasError = false;
    notifyListeners();
  }

  void setError(bool value) {
    _hasError = value;
    notifyListeners();
  }

  void updateDisplayName(String value) {
    if (_displayName == value) return;
    _displayName = value;
    if (_hasError) {
      _hasError = false;
    }
    notifyListeners();
  }

  void updateOccupation(String value) {
    if (_occupation == value) return;
    _occupation = value;
    _hasError = false;
    notifyListeners();
  }

  void toggleGoal(String goal) {
    if (_goals.contains(goal)) {
      _goals.remove(goal);
    } else {
      _goals.add(goal);
    }
    _hasError = false;
    notifyListeners();
  }

  void updateCurrency(String value) {
    if (_currencyCode == value) return;
    _currencyCode = value;
    _hasError = false;
    notifyListeners();
  }

  void updateInitialBalance(double value) {
    if (_initialBalance == value) return;
    _initialBalance = value;
    _hasError = false;
    notifyListeners();
  }

  bool canContinue() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _occupation != null;
      case 2:
        return _goals.isNotEmpty;
      case 3:
        return _currencyCode != null;
      case 4:
        final balance = _initialBalance ?? 0.0;
        return balance <= 999999999;
      default:
        return false;
    }
  }

  Future<void> saveOnboarding({
    required String email,
  }) async {
    _setLoading(true);
    try {
      final entity = OnboardingEntity(
        displayName: _displayName,
        occupation: _occupation,
        goals: _goals,
        currencyCode: _currencyCode,
        initialBalance: _initialBalance,
        onboardingCompleted: false,
      );
      await saveOnboardingUseCase(
        email: email,
        entity: entity,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeOnboarding({
    required String email,
  }) async {
    _setLoading(true);
    try {
      final temporaryEntity = OnboardingEntity(
        displayName: _displayName,
        occupation: _occupation,
        goals: _goals,
        currencyCode: _currencyCode,
        initialBalance: _initialBalance,
        onboardingCompleted: true,
      );
      await completeOnboardingUseCase(
        email: email,
        entity: temporaryEntity,
      );
      debugPrint(
          '[Onboarding ViewModel]: Onboarding pipeline completed successfully for $email.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOnboarding({
    required String email,
  }) async {
    _setLoading(true);
    try {
      final onboarding = await getOnboardingUseCase(
        email: email,
      );
      if (onboarding == null) return;
      _displayName = onboarding.displayName;
      _occupation = onboarding.occupation;
      _goals
        ..clear()
        ..addAll(onboarding.goals);
      _currencyCode = onboarding.currencyCode;
      _initialBalance = onboarding.initialBalance;
      _hasError = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isCompleted({
    required String email,
  }) async {
    return checkOnboardingUseCase(
      email: email,
    );
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  // TÍNH NĂNG MỚI: Giải phóng bộ nhớ StreamController khi hủy ViewModel
  @override
  void dispose() {
    _shakeController.close();
    super.dispose();
  }
}
