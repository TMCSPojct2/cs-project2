import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/account_rules.dart';
import '../data/language_controller.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _codeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _sending = false;
  bool _verifying = false;
  bool _updating = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  int _step = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        children: [
          BrandHeader(
            subtitle: LanguageController.text('Password reset and account recovery', 'استعادة كلمة المرور'),
            trailing: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
          ),
          const SizedBox(height: 24),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SurfaceCard(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: _step == 0 ? _emailStep(context) : _step == 1 ? _codeStep(context) : _passwordStep(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailStep(BuildContext context) {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: const ValueKey('email'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AccentPill(label: 'RECOVERY', icon: Icons.lock_reset_rounded),
          const SizedBox(height: 16),
          Text(LanguageController.text('Reset access securely.', 'استعد الوصول بأمان.'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(LanguageController.text('Enter your email and NABIH will send a verification code.', 'أدخل بريدك وسيتم إرسال رمز تحقق.'), style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: LanguageController.text('Email', 'البريد الإلكتروني'), hintText: 'name@uqu.edu.sa', prefixIcon: const Icon(Icons.mail_outline_rounded)),
            validator: _validateEmail,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _sendCode,
              icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Icon(Icons.mail_outline_rounded),
              label: Text(_sending ? LanguageController.text('Sending...', 'جاري الإرسال...') : LanguageController.text('Send Code', 'إرسال الرمز')),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeStep(BuildContext context) {
    final email = cleanEmail(_emailController.text);
    return Form(
      key: _codeFormKey,
      child: Column(
        key: const ValueKey('code'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AccentPill(label: 'VERIFY', icon: Icons.password_rounded),
          const SizedBox(height: 16),
          Text(LanguageController.text('Enter the reset code.', 'أدخل رمز الاستعادة.'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(LanguageController.text('The code was sent to $email.', 'تم إرسال الرمز إلى $email.'), style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _verifyCode(),
            decoration: InputDecoration(labelText: LanguageController.text('Verification Code', 'رمز التحقق'), prefixIcon: const Icon(Icons.password_rounded)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return LanguageController.text('Enter the code', 'أدخل الرمز');
              if (value.trim().length < 4) return LanguageController.text('Enter the full code', 'أدخل الرمز كاملًا');
              return null;
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _verifying ? null : _verifyCode,
              icon: _verifying ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Icon(Icons.verified_outlined),
              label: Text(_verifying ? LanguageController.text('Verifying...', 'جاري التحقق...') : LanguageController.text('Verify Code', 'تأكيد الرمز')),
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
          Center(child: TextButton(onPressed: _sending ? null : _sendCode, child: Text(LanguageController.text('Resend code', 'إعادة إرسال الرمز')))),
        ],
      ),
    );
  }

  Widget _passwordStep(BuildContext context) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        key: const ValueKey('password'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AccentPill(label: 'NEW PASSWORD', icon: Icons.lock_outline_rounded),
          const SizedBox(height: 16),
          Text(LanguageController.text('Choose a new password.', 'اختر كلمة مرور جديدة.'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(LanguageController.text('Use at least 8 characters.', 'استخدم 8 أحرف على الأقل.'), style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          TextFormField(
            controller: _passwordController,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              labelText: LanguageController.text('New Password', 'كلمة المرور الجديدة'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _hideConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _updatePassword(),
            decoration: InputDecoration(
              labelText: LanguageController.text('Confirm Password', 'تأكيد كلمة المرور'),
              prefixIcon: const Icon(Icons.lock_reset_outlined),
              suffixIcon: IconButton(onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword), icon: Icon(_hideConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
            ),
            validator: _validatePasswordMatch,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _updating ? null : _updatePassword,
              icon: _updating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Icon(Icons.check_circle_outline_rounded),
              label: Text(_updating ? LanguageController.text('Saving...', 'جاري الحفظ...') : LanguageController.text('Save Password', 'حفظ كلمة المرور')),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return LanguageController.text('Enter your email', 'أدخل البريد الإلكتروني');
    final email = cleanEmail(value);
    if (!email.contains('@') || !email.contains('.')) return LanguageController.text('Enter a valid email address', 'أدخل بريدًا صحيحًا');
    if (!isAcceptedRegistrationEmail(email)) return LanguageController.text('Use your Umm Al Qura University email', 'استخدم بريد جامعة أم القرى');
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return LanguageController.text('Enter a password', 'أدخل كلمة المرور');
    if (value.trim().length < 8) return LanguageController.text('Password must be at least 8 characters', 'كلمة المرور يجب ألا تقل عن 8 أحرف');
    return null;
  }

  String? _validatePasswordMatch(String? value) {
    final passwordError = _validatePassword(value);
    if (passwordError != null) return passwordError;
    if (value!.trim() != _passwordController.text.trim()) return LanguageController.text('Passwords do not match', 'كلمتا المرور غير متطابقتين');
    return null;
  }

  Future<void> _sendCode() async {
    if (_step == 0) {
      final valid = _emailFormKey.currentState?.validate() ?? false;
      if (!valid) return;
    }
    setState(() => _sending = true);
    try {
      await AuthService.instance.sendPasswordResetCode(cleanEmail(_emailController.text));
      if (!mounted) return;
      setState(() => _step = 1);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Code sent to your email', 'تم إرسال الرمز إلى بريدك'))));
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Unable to send the code right now', 'تعذر إرسال الرمز الآن'))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _verifyCode() async {
    final valid = _codeFormKey.currentState?.validate() ?? false;
    if (!valid) return;
    setState(() => _verifying = true);
    try {
      await AuthService.instance.verifyPasswordResetCode(email: cleanEmail(_emailController.text), code: _codeController.text.trim());
      if (!mounted) return;
      setState(() => _step = 2);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Unable to verify the code right now', 'تعذر التحقق من الرمز الآن'))));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _updatePassword() async {
    final valid = _passwordFormKey.currentState?.validate() ?? false;
    if (!valid) return;
    setState(() => _updating = true);
    try {
      await AuthService.instance.updatePassword(_passwordController.text.trim());
      await AuthService.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Password updated. Please sign in.', 'تم تحديث كلمة المرور. سجل الدخول من جديد.'))));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Unable to update the password right now', 'تعذر تحديث كلمة المرور الآن'))));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }
}
