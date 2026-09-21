class UserProfile {
  final String fullName;
  final String email;
  final String employeeId;
  final String schoolName;
  final String designation;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.employeeId,
    required this.schoolName,
    this.designation = 'Senior Teacher',
  });

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? employeeId,
    String? schoolName,
    String? designation,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      schoolName: schoolName ?? this.schoolName,
      designation: designation ?? this.designation,
    );
  }
}
