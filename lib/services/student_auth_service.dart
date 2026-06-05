import 'package:flutter/foundation.dart';

import '../models/student_user.dart';

class StudentAuthService extends ChangeNotifier {
  StudentUser? _currentStudent;

  StudentUser? get currentStudent => _currentStudent;

  bool get isLoggedIn => _currentStudent != null;

  bool login({required String identifier, required String password}) {
    final cleanIdentifier = identifier.trim();

    if (cleanIdentifier.isEmpty || password.isEmpty) {
      return false;
    }

    // Demo-only account until the project has a real student database.
    _currentStudent = StudentUser(
      studentId: '2026-0001',
      displayName: cleanIdentifier,
    );
    notifyListeners();
    return true;
  }

  void logout() {
    _currentStudent = null;
    notifyListeners();
  }
}
