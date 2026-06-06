import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/account_rules.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/admin_data_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BrandHeader(
                      subtitle: LanguageController.text('Secure access to your university workspace', 'دخول آمن لمساحتك الجامعية'),
                      trailing: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SurfaceCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(LanguageController.text('Welcome back.', 'مرحبًا بعودتك.'), style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text(
                              LanguageController.text(
                                'Sign in with your university email and password. Your saved profile will open the correct workspace.',
                                'سجّل الدخول بالبريد الجامعي وكلمة المرور، وسيتم فتح المساحة المناسبة حسب ملفك المحفوظ.',
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: LanguageController.text('University Email', 'البريد الجامعي'),
                                hintText: 'name@uqu.edu.sa',
                                prefixIcon: const Icon(Icons.mail_outline_rounded),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: LanguageController.text('Password', 'كلمة المرور'),
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                                  icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    LanguageController.text('Role is loaded from your university profile.', 'يتم تحميل الدور من ملفك الجامعي.'),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                  child: Text(LanguageController.text('Forgot password?', 'نسيت كلمة المرور؟')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _submitting ? null : _submit,
                                icon: _submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(_submitting ? LanguageController.text('Signing in...', 'جاري الدخول...') : LanguageController.text('Login', 'تسجيل الدخول')),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(58),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: _submitting ? null : () => Navigator.pushReplacementNamed(context, '/register'),
                                child: Text(LanguageController.text("Don't have an account? Create Account", 'ليس لديك حساب؟ أنشئ حسابًا')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LanguageController.text('Enter your university email', 'أدخل بريدك الجامعي');
    }
    final email = value.trim().toLowerCase();
    if (!email.contains('@') || !email.contains('.')) {
      return LanguageController.text('Enter a valid email address', 'أدخل بريدًا صحيحًا');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LanguageController.text('Enter your password', 'أدخل كلمة المرور');
    }
    if (value.trim().length < 8) {
      return LanguageController.text('Password must be at least 8 characters', 'كلمة المرور يجب ألا تقل عن 8 أحرف');
    }
    return null;
  }

  UserRole _fallbackRoleFromEmail(String email) {
    final clean = cleanEmail(email);
    if (isAcceptedRegistrationEmail(clean)) {
      return roleFromRegistrationEmail(clean);
    }
    return UserRole.student;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Please complete the required fields correctly', 'أكمل الحقول المطلوبة بشكل صحيح'))));
      return;
    }

    setState(() => _submitting = true);
    try {
      final email = _emailController.text.trim();
      final response = await AuthService.instance.signIn(
        email: email,
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Unable to sign in with these credentials.');
      }

      var profile = await ProfileService.instance.getProfile(user.id);
      if (profile == null) {
        final metadata = user.userMetadata ?? const <String, dynamic>{};
        final invitedRoleStr = await AdminDataService.instance.getRoleByEmail(email);
        final profileRole = invitedRoleStr != null
            ? userRoleFromValue(invitedRoleStr, fallback: _fallbackRoleFromEmail(email))
            : userRoleFromValue(metadata['role'], fallback: _fallbackRoleFromEmail(email));
        final profileName = metadata['full_name']?.toString().trim().isNotEmpty == true
            ? metadata['full_name'].toString().trim()
            : email.split('@').first;
        final profileId = metadata['university_id']?.toString().trim() ?? '';
        await ProfileService.instance.upsertProfile(
          id: user.id,
          fullName: profileName,
          email: user.email ?? email,
          role: profileRole.dbValue,
          universityId: profileId,
        );
        profile = await ProfileService.instance.getProfile(user.id);
      }

      if (profile == null) {
        throw const AuthException('Your profile could not be loaded.');
      }

      final actualRole = userRoleFromValue(profile['role'], fallback: _fallbackRoleFromEmail(email));
      setActiveSessionProfile(
        SessionProfile(
          name: profile['full_name'] as String? ?? 'User',
          email: profile['email'] as String? ?? user.email ?? email,
          universityId: profile['university_id'] as String? ?? '',
          role: actualRole,
        ),
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, actualRole.homeRoute, (route) => false, arguments: actualRole);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Something went wrong while signing in', 'حدث خطأ أثناء تسجيل الدخول'))));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
