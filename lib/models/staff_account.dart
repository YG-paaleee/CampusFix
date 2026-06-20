class StaffAccount {
  const StaffAccount({
    required this.staffId,
    required this.fullName,
    required this.email,
    required this.specialty,
    this.isActive = true,
  });

  final String staffId;
  final String fullName;
  final String email;
  final String specialty;
  final bool isActive;

  StaffAccount copyWith({
    String? staffId,
    String? fullName,
    String? email,
    String? specialty,
    bool? isActive,
  }) {
    return StaffAccount(
      staffId: staffId ?? this.staffId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      specialty: specialty ?? this.specialty,
      isActive: isActive ?? this.isActive,
    );
  }

  factory StaffAccount.fromJson(Map<String, dynamic> json) {
    return StaffAccount(
      staffId: json['staffId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'fullName': fullName,
      'email': email,
      'specialty': specialty,
      'isActive': isActive,
    };
  }
}
