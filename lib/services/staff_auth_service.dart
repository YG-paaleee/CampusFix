import 'package:flutter/foundation.dart';

import 'admin_staff_service.dart';

class StaffAuthService extends ChangeNotifier {
  StaffAuthService(this._staffService);

  final AdminStaffService _staffService;

  String? _currentStaffId;
  String? _currentStaffName;
  String? _errorMessage;

  bool get isLoggedIn => _currentStaffId != null;
  String? get currentStaffId => _currentStaffId;
  String? get currentStaffName => _currentStaffName;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Mock authentication delay.
    await Future.delayed(const Duration(milliseconds: 600));

    // Authenticate against the staff accounts the admin manages, so any active
    // staff member can sign in and only sees the reports assigned to them.
    final staff = _staffService.findByEmail(email);

    if (staff == null) {
      _errorMessage = 'No staff account found for that email.';
      notifyListeners();
      return false;
    }

    if (!staff.isActive) {
      _errorMessage = 'This staff account has been deactivated.';
      notifyListeners();
      return false;
    }

    // Shared demo password for every staff account.
    if (password != 'password') {
      _errorMessage = 'Invalid staff credentials.';
      notifyListeners();
      return false;
    }

    _currentStaffId = staff.staffId;
    _currentStaffName = staff.fullName;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentStaffId = null;
    _currentStaffName = null;
    _errorMessage = null;
    notifyListeners();
  }
}
