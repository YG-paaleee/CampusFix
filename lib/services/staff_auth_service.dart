import 'package:flutter/foundation.dart';

class StaffAuthService extends ChangeNotifier {
  String? _currentStaffId;
  String? _errorMessage;

  bool get isLoggedIn => _currentStaffId != null;
  String? get currentStaffId => _currentStaffId;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Mock authentication delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (email == 'staff@campus.edu' && password == 'password') {
      _currentStaffId = 'STAFF-001'; // Mock staff ID
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Invalid staff credentials.';
    notifyListeners();
    return false;
  }

  void logout() {
    _currentStaffId = null;
    _errorMessage = null;
    notifyListeners();
  }
}
