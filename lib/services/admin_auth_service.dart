import 'package:flutter/foundation.dart';

class AdminAuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Mock authentication delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (email == 'admin@campus.edu' && password == 'password') {
      _isLoggedIn = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Invalid admin credentials.';
    notifyListeners();
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }
}
