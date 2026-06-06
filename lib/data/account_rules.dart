import 'role_context.dart';

const String universityEmailDomain = '@uqu.edu.sa';

String cleanEmail(String value) => value.trim().toLowerCase();

bool isUniversityEmail(String email) => cleanEmail(email).endsWith(universityEmailDomain);

bool isAcceptedRegistrationEmail(String email) => isUniversityEmail(email);

UserRole roleFromRegistrationEmail(String email) {
  final local = cleanEmail(email).split('@').first;
  final isStudent = local.length >= 2 &&
      local.startsWith('s') &&
      RegExp(r'^\d').hasMatch(local.substring(1));
  return isStudent ? UserRole.student : UserRole.faculty;
}
