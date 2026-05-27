import 'package:flutter/material.dart';

import '../../domain/entities/onboarding_entity.dart';

import '../../domain/usecases/check_onboarding_usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import '../../domain/usecases/get_onboarding_usecase.dart';
import '../../domain/usecases/save_onboarding_usecase.dart';

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

  // onboarding steps

  int _currentStep = 0;

  int get currentStep => _currentStep;

  // loading state

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  //error if null field
  bool _hasError = false;
  bool get hasError => _hasError;

  // onboarding data

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

  // navigation

  void nextStep() {
    _currentStep++;
    _hasError = false;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep == 0) {
      return;
    }

    _currentStep--;
    _hasError = false;
    notifyListeners();
  }

  void setError(bool value) {
    _hasError = value;
    notifyListeners();
  }

  // update methods

  void updateDisplayName(String value) {
    if (_displayName == value) return;

    _displayName = value;

    if (_hasError) {
      _hasError = false;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void updateOccupation(String value) {
    _occupation = value;
    _hasError = false;
    notifyListeners();
  }

  void toggleGoal(
    String goal,
  ) {
    if (_goals.contains(goal)) {
      _goals.remove(goal);
    } else {
      _goals.add(goal);
    }
    _hasError = false;
    notifyListeners();
  }

  void updateCurrency(String value) {
    _currencyCode = value;
    _hasError = false;
    notifyListeners();
  }

  void updateInitialBalance(double value) {
    _initialBalance = value;
    _hasError = false;
    notifyListeners();
  }

  // validation

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
        return _initialBalance != null;

      default:
        return false;
    }
  }

  // save onboarding state

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

  // complete onboarding

  Future<void> completeOnboarding({
    required String email,
  }) async {
    _setLoading(true);

    try {
      await completeOnboardingUseCase(
        email: email,
      );
    } finally {
      _setLoading(false);
    }
  }

  // restore onboarding state

  Future<void> loadOnboarding({
    required String email,
  }) async {
    _setLoading(true);

    try {
      final onboarding = await getOnboardingUseCase(
        email: email,
      );

      if (onboarding == null) {
        return;
      }

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

  // onboarding lifecycle check

  Future<bool> isCompleted({
    required String email,
  }) async {
    return checkOnboardingUseCase(
      email: email,
    );
  }

  void _setLoading(
    bool value,
  ) {
    _isLoading = value;

    notifyListeners();
  }
}
