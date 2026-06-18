import 'package:flutter/material.dart';

class BudgetFormViewModel extends ChangeNotifier {
  String _name = '';
  double _amount = 0.0;
  String? _errorMessage;

  String get name => _name;
  double get amount => _amount;
  String? get errorMessage => _errorMessage;

  void updateName(String val) {
    _name = val.trim();
    _validate();
  }

  void updateAmount(String val) {
    _amount = double.tryParse(val) ?? 0.0;
    _validate();
  }

  bool _validate() {
    if (_name.isEmpty) {
      _errorMessage = 'Tên ngân sách không được để trống';
      notifyListeners();
      return false;
    }
    if (_amount <= 0) {
      _errorMessage = 'Số tiền ngân sách phải lớn hơn 0';
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  bool submitable() => _validate() && _errorMessage == null;
}
