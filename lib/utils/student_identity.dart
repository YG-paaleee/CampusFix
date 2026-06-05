const psuEmailDomain = 'psu.palawan.edu.ph';

final _studentIdPattern = RegExp(r'^\d{4}-\d-\d{4}$');
final _studentEmailPattern = RegExp(r'^\d{9}@psu\.palawan\.edu\.ph$');

bool isValidStudentId(String value) {
  return _studentIdPattern.hasMatch(value.trim());
}

bool isValidPsuStudentEmail(String value) {
  return _studentEmailPattern.hasMatch(value.trim().toLowerCase());
}

String emailFromStudentId(String studentId) {
  return '${studentId.trim().replaceAll('-', '')}@$psuEmailDomain';
}

String studentIdFromEmail(String email) {
  final localPart = email.trim().toLowerCase().split('@').first;

  if (localPart.length != 9) {
    return email.trim();
  }

  return '${localPart.substring(0, 4)}-${localPart.substring(4, 5)}-${localPart.substring(5)}';
}

String? normalizeStudentLoginIdentifier(String identifier) {
  final value = identifier.trim().toLowerCase();

  if (isValidStudentId(value)) {
    return emailFromStudentId(value);
  }

  if (isValidPsuStudentEmail(value)) {
    return value;
  }

  return null;
}
