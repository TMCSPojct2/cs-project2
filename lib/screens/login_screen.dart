import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import 'register_screen.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _lang = LanguageService.instance;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _lang.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  Future<void> _login() async {
    setState(() { _errorMessage = null; _isLoading = true; });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() { _errorMessage = _lang.tr('email_required'); _isLoading = false; });
      return;
    }

    try {
      await AuthService.signIn(email: email, password: password);
      final profile = await AuthService.getProfile();
      if (!mounted) return;

      if (profile == null) {
        setState(() { _errorMessage = _lang.tr('login_failed'); _isLoading = false; });
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeShell(profile: profile)),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = e.message; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = _lang.tr('login_failed'); _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _lang.removeListener(_rebuild);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = _lang.tr;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Language toggle
                  Align(
                    alignment: _lang.isArabic ? Alignment.topLeft : Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => _lang.toggle(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: NabihTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, size: 16, color: NabihTheme.primary),
                            const SizedBox(width: 4),
                            Text(_lang.isArabic ? 'EN' : 'عربي',
                                style: const TextStyle(color: NabihTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: NabihTheme.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Center(
                      child: Text('N', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(tr('login_title'),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: NabihTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(tr('login_subtitle'), style: const TextStyle(fontSize: 15, color: NabihTheme.textSecondary)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: tr('email'),
                      hintText: tr('email_hint'),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: tr('password'),
                      hintText: tr('password_hint'),
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: NabihTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 18, color: NabihTheme.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: NabihTheme.error, fontSize: 13))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(tr('sign_in')),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: tr('no_account'), style: const TextStyle(color: NabihTheme.textSecondary)),
                        TextSpan(text: tr('register'), style: const TextStyle(color: NabihTheme.primary, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
