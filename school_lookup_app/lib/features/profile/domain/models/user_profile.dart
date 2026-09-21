class UserProfile {
  final String fullName;
  final String email;
  final String employeeId;
  final String schoolName;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.employeeId,
    required this.schoolName,
  });

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? employeeId,
    String? schoolName,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      schoolName: schoolName ?? this.schoolName,
    );
  }
}
