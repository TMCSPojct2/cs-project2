import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/account_rules.dart';
import '../data/auth_flow_args.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/auth_service.dart';
import '../services/local_notification_service.dart';
import '../services/pin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  UserRole _role = UserRole.student;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateDetectedRole);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateDetectedRole);
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateDetectedRole() {
    final nextRole = _roleFromEmail(_emailController.text);
    if (nextRole != null && nextRole != _role) {
      setState(() => _role = nextRole);
    }
  }

  UserRole? _roleFromEmail(String value) {
    final email = cleanEmail(value);
    if (!isAcceptedRegistrationEmail(email)) {
      return null;
    }
    return roleFromRegistrationEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: SurfaceCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AccentPill(label: LanguageController.text('REGISTRATION', 'إنشاء حساب'), icon: Icons.person_add_alt_1_rounded),
                    const SizedBox(height: 16),
                    Text(LanguageController.text('Create your NABIH account.', 'أنشئ حسابك في NABIH.'), style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      LanguageController.text(
                        'Use your Umm Al Qura University email. The workspace is detected automatically from your email.',
                        'استخدم بريد جامعة أم القرى، وسيتم تحديد المساحة المناسبة تلقائيًا من البريد.',
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: LanguageController.text('Full Name', 'الاسم الكامل'),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) => _required(value, LanguageController.text('Enter your full name', 'أدخل الاسم الكامل')),
                    ),
                    const SizedBox(height: 14),
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
                    _DetectedRoleCard(role: _role, validDomain: isAcceptedRegistrationEmail(_emailController.text)),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _idController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: LanguageController.text('University ID / Employee ID', 'الرقم الجامعي / الوظيفي'),
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      validator: _validateId,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _hideConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: LanguageController.text('Confirm Password', 'تأكيد كلمة المرور'),
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                          icon: Icon(_hideConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        ),
                      ),
                      validator: _validatePasswordMatch,
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
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: Text(_submitting ? LanguageController.text('Creating account...', 'جاري إنشاء الحساب...') : LanguageController.text('Create Account', 'إنشاء حساب')),
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
                        onPressed: _submitting ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(LanguageController.text('Already have an account? Login', 'لديك حساب؟ سجل الدخول')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final requiredMessage = _required(value, LanguageController.text('Enter your university email', 'أدخل البريد الجامعي'));
    if (requiredMessage != null) {
      return requiredMessage;
    }
    final email = value!.trim().toLowerCase();
    if (!email.contains('@') || !email.contains('.')) {
      return LanguageController.text('Enter a valid email address', 'أدخل بريدًا صحيحًا');
    }
    if (!isAcceptedRegistrationEmail(email)) {
      return LanguageController.text('Use your Umm Al Qura University email', 'استخدم بريد جامعة أم القرى');
    }
    return null;
  }

  String? _validateId(String? value) {
    final requiredMessage = _required(value, LanguageController.text('Enter your university ID or employee ID', 'أدخل الرقم الجامعي أو الوظيفي'));
    if (requiredMessage != null) {
      return requiredMessage;
    }
    final id = value!.trim();
    if (id.length < 6) {
      return LanguageController.text('Enter a longer ID value', 'أدخل رقمًا أطول');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final requiredMessage = _required(value, LanguageController.text('Enter a password', 'أدخل كلمة المرور'));
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (value!.trim().length < 8) {
      return LanguageController.text('Password must be at least 8 characters', 'كلمة المرور يجب ألا تقل عن 8 أحرف');
    }
    return null;
  }

  String? _validatePasswordMatch(String? value) {
    final requiredMessage = _required(value, LanguageController.text('Confirm your password', 'أكد كلمة المرور'));
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (value!.trim() != _passwordController.text.trim()) {
      return LanguageController.text('Passwords do not match', 'كلمتا المرور غير متطابقتين');
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Please complete the required fields correctly', 'أكمل الحقول المطلوبة بشكل صحيح'))));
      return;
    }

    final email = cleanEmail(_emailController.text);
    final detectedRole = _roleFromEmail(email);
    if (detectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Use your Umm Al Qura University email', 'استخدم بريد جامعة أم القرى'))));
      return;
    }

    setState(() {
      _role = detectedRole;
      _submitting = true;
    });

    try {
      final password = _passwordController.text.trim();
      final fullName = _nameController.text.trim();
      final universityId = _idController.text.trim();
      final response = await AuthService.instance.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': detectedRole.dbValue,
          'university_id': universityId,
        },
      );

      final user = response.user;
      if (user == null) throw const AuthException('Account could not be created.');

      final pin = PinService.instance.createPin();
      bool notified = false;
      try { notified = await LocalNotificationService.instance.showPin(pin); } catch (_) {}

      if (!mounted) return;
      if (!notified) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text(LanguageController.text('Your Verification Code', 'رمز التحقق الخاص بك')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(LanguageController.text('Enter this code on the next screen:', 'أدخل هذا الرمز في الشاشة التالية:')),
                const SizedBox(height: 16),
                Text(
                  pin,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 10),
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageController.text('Valid for 15 minutes.', 'صالح لمدة 15 دقيقة.'),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(LanguageController.text('Got it', 'حسنًا')),
              ),
            ],
          ),
        );
      }

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/verify-email',
        arguments: SignupVerificationArgs(
          userId: user.id,
          email: email,
          password: password,
          fullName: fullName,
          universityId: universityId,
          role: detectedRole,
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      final msg = error.message.toLowerCase();
      final display = (msg.contains('rate') || msg.contains('limit') || msg.contains('too many'))
          ? LanguageController.text('Email rate limit reached. Wait a few minutes and try again.', 'تم تجاوز حد الإرسال. انتظر بضع دقائق وأعد المحاولة.')
          : (msg.contains('already') || msg.contains('registered') || msg.contains('exists'))
              ? LanguageController.text('This email is already registered. Try signing in.', 'البريد مسجل مسبقًا. جرب تسجيل الدخول.')
              : error.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(display)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Something went wrong while creating the account', 'حدث خطأ أثناء إنشاء الحساب'))));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _DetectedRoleCard extends StatelessWidget {
  final UserRole role;
  final bool validDomain;
  const _DetectedRoleCard({required this.role, required this.validDomain});

  @override
  Widget build(BuildContext context) {
    final color = validDomain ? AppColors.primary : AppColors.secondary;
    final label = validDomain
        ? LanguageController.text('Detected workspace: ${role.label}', 'المساحة المحددة: ${role.label}')
        : LanguageController.text('Use @uqu.edu.sa to detect your workspace', 'استخدم @uqu.edu.sa لتحديد المساحة');
    final body = validDomain
        ? LanguageController.text('Student emails start with s. Other Umm Al Qura emails continue as Faculty.', 'بريد الطالب يبدأ بحرف s، وبقية بريد جامعة أم القرى يستمر كعضو هيئة تدريس.')
        : LanguageController.text('Only Umm Al Qura University email is accepted.', 'يُقبل بريد جامعة أم القرى فقط.');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: validDomain ? AppColors.mist : AppColors.sand.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(validDomain ? iconForRole(role) : Icons.info_outline_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
