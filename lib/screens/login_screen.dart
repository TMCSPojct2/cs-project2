import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../data/demo_data.dart';
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
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final Map<String, String> _demoAccounts = {
    's444006391@uqu.edu.sa': 'Student',
    'kalfalqi@uqu.edu.sa': 'Faculty',
    'ahassan@staff.uqu.edu.sa': 'Staff',
    'visitor@gmail.com': 'Visitor',
  };

  void _login() {
    setState(() { _errorMessage = null; _isLoading = true; });

    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty || _passwordController.text.isEmpty) {
      setState(() { _errorMessage = 'Please enter email and password'; _isLoading = false; });
      return;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      AppUser? user;
      for (final u in DemoData.allUsers) {
        if (u.email.toLowerCase() == email) {
          user = u;
          break;
        }
      }

      // Allow any email - assign role based on email pattern
      user ??= AppUser(
        id: 'custom',
        name: email.split('@').first,
        email: email,
        role: AppUser.roleFromEmail(email),
      );

      setState(() { _isLoading = false; });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeShell(user: user!)),
      );
    });
  }

  void _quickLogin(AppUser user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeShell(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: NabihTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('N', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: NabihTheme.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Sign in to continue', style: TextStyle(fontSize: 15, color: NabihTheme.textSecondary)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage!, style: const TextStyle(color: NabihTheme.error, fontSize: 14)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: const Text("Don't have an account? Register"),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Quick Demo Login', style: TextStyle(fontSize: 13, color: NabihTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _demoChip('Student', Icons.school, DemoData.demoStudent),
                      _demoChip('Faculty', Icons.person, DemoData.demoFaculty),
                      _demoChip('Staff', Icons.badge, DemoData.demoStaff),
                      _demoChip('Visitor', Icons.group, DemoData.demoVisitor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoChip(String label, IconData icon, AppUser user) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: NabihTheme.primary),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: () => _quickLogin(user),
      backgroundColor: NabihTheme.primary.withValues(alpha: 0.08),
      side: BorderSide(color: NabihTheme.primary.withValues(alpha: 0.3)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
