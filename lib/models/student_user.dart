class StudentUser {
  const StudentUser({
    required this.uid,
    required this.studentId,
    required this.displayName,
    required this.email,
  });

  final String uid;
  final String studentId;
  final String displayName;
  final String email;

  factory StudentUser.fromJson(Map<String, dynamic> json) {
    return StudentUser(
      uid: json['uid']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'studentId': studentId,
      'displayName': displayName,
      'email': email,
      'role': 'student',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
