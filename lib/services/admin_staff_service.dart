import 'package:flutter/foundation.dart';
import '../models/staff_account.dart';

class AdminStaffService extends ChangeNotifier {
  List<StaffAccount> _staffMembers = [];

  AdminStaffService() {
    _initMockData();
  }

  List<StaffAccount> get staffMembers => _staffMembers;

  /// Only staff who are currently active can be assigned new work or sign in.
  List<StaffAccount> get activeStaff =>
      _staffMembers.where((s) => s.isActive).toList();

  /// Find a staff member by email (case-insensitive). Used for staff login.
  StaffAccount? findByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final staff in _staffMembers) {
      if (staff.email.trim().toLowerCase() == normalized) {
        return staff;
      }
    }
    return null;
  }

  void _initMockData() {
    _staffMembers = [
      const StaffAccount(
        staffId: 's1',
        fullName: 'John Doe',
        email: 'john.doe@campus.edu',
        specialty: 'Electrician',
      ),
      const StaffAccount(
        staffId: 's2',
        fullName: 'Jane Smith',
        email: 'jane.smith@campus.edu',
        specialty: 'Plumber',
      ),
      const StaffAccount(
        staffId: 's3',
        fullName: 'Mike Johnson',
        email: 'mike.j@campus.edu',
        specialty: 'General Maintenance',
      ),
    ];
    notifyListeners();
  }

  void addStaff(StaffAccount newStaff) {
    _staffMembers.add(newStaff);
    notifyListeners();
  }

  void toggleStaffStatus(String staffId) {
    final index = _staffMembers.indexWhere((s) => s.staffId == staffId);
    if (index != -1) {
      _staffMembers[index] = _staffMembers[index].copyWith(
        isActive: !_staffMembers[index].isActive,
      );
      notifyListeners();
    }
  }

  void editStaffDetails(String staffId, String newName, String newSpecialty) {
    final index = _staffMembers.indexWhere((s) => s.staffId == staffId);
    if (index != -1) {
      _staffMembers[index] = _staffMembers[index].copyWith(
        fullName: newName,
        specialty: newSpecialty,
      );
      notifyListeners();
    }
  }
}
