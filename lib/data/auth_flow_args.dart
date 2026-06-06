import 'role_context.dart';

class SignupVerificationArgs {
  final String userId;
  final String email;
  final String password;
  final String fullName;
  final String universityId;
  final UserRole role;

  const SignupVerificationArgs({
    required this.userId,
    required this.email,
    required this.password,
    required this.fullName,
    required this.universityId,
    required this.role,
  });
}
