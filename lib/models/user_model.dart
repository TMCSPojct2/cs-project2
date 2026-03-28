enum UserRole { student, faculty, staff, visitor }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final String? studentId;
  final String? phone;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.studentId,
    this.phone,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.staff:
        return 'Staff';
      case UserRole.visitor:
        return 'Visitor';
    }
  }

  static UserRole roleFromEmail(String email) {
    if (RegExp(r'^s\d+@').hasMatch(email)) return UserRole.student;
    if (email.endsWith('@uqu.edu.sa')) return UserRole.faculty;
    if (email.endsWith('@staff.uqu.edu.sa')) return UserRole.staff;
    return UserRole.visitor;
  }
}
