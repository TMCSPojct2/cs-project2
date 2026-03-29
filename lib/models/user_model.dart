import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

enum UserRole { student, faculty, staff, visitor }

UserRole userRoleFromString(String role) {
  switch (role) {
    case 'student':
      return UserRole.student;
    case 'faculty':
      return UserRole.faculty;
    case 'staff':
      return UserRole.staff;
    case 'visitor':
      return UserRole.visitor;
    default:
      return UserRole.visitor;
  }
}

String userRoleToString(UserRole role) {
  return role.name;
}


@JsonSerializable()
class AppUser {
  final String id;
  final String name;

  final String email;
  @JsonKey(fromJson: userRoleFromString, toJson: userRoleToString)
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

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);


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
    final lower = email.toLowerCase();
    if (RegExp(r'^s\d+@uqu\.edu\.sa$').hasMatch(lower)) return UserRole.student;
    if (lower.endsWith('@uqu.edu.sa')) return UserRole.faculty; // default; overridden at registration
    return UserRole.visitor;
  }
}
