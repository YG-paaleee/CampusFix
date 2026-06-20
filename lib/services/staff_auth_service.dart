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
      // Must match a staff id the admin can assign (see AdminStaffService and
      // the assignable list in AdminReportManagementScreen), otherwise this
      // staff member would never see any reports assigned to them.
      _currentStaffId = 's1'; // John Doe
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
