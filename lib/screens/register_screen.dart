import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import 'home_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _lang = LanguageService.instance;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;
  String? _detectedRole;
  // 'faculty' or 'staff' — only shown when email is uqu.edu.sa non-student
  String _uniRoleChoice = 'faculty';

  // Resend OTP countdown (180 seconds = 3 minutes)
  int _resendCountdown = 180;
  Timer? _countdownTimer;

  void _startCountdown() {
    _resendCountdown = 180;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown <= 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  String _roleFromEmail(String email) {
    final lower = email.toLowerCase();
    if (RegExp(r'^s\d+@uqu\.edu\.sa$').hasMatch(lower)) return 'student';
    if (lower.endsWith('@uqu.edu.sa')) return _uniRoleChoice; // faculty or staff chosen by user
    return 'visitor';
  }

  bool _showUniRoleToggle(String email) {
    final lower = email.toLowerCase();
    return lower.endsWith('@uqu.edu.sa') &&
        !RegExp(r'^s\d+@uqu\.edu\.sa$').hasMatch(lower);
  }

  void _detectRole(String email) {
    setState(() {
      _detectedRole = email.contains('@') ? _roleFromEmail(email) : null;
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();

    try {
      // Send real Supabase OTP email to everyone
      await AuthService.sendOtp(email: email);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent to your email'),
          backgroundColor: NabihTheme.success,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }



  Future<void> _verifyAndRegister() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();

    try {
      await AuthService.completeRegistration(
        email: email,
        token: otp,
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        roleOverride: _showUniRoleToggle(email) ? _uniRoleChoice : null,
      );

      final profile = await AuthService.getProfile();
      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load profile. Please try signing in.';
        });
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeShell(profile: profile)),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Verification failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_lang.tr('create_account'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_add_rounded,
                      size: 64,
                      color: NabihTheme.primary,
                    ),
                    const SizedBox(height: 24),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      enabled: !_otpSent,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _lang.tr('full_name'),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email field with role chip
                    TextFormField(
                      controller: _emailController,
                      enabled: !_otpSent,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _lang.tr('email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixIcon: _detectedRole != null
                            ? Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text(
                                    _detectedRole!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: NabihTheme.primary,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                            : null,
                      ),
                      onChanged: _detectRole,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Role info box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NabihTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: NabihTheme.secondary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Role is auto-assigned based on email:\n'
                              's12345@uqu.edu.sa = Student\n'
                              'name@uqu.edu.sa = Faculty or Staff (your choice)\n'
                              'Other = Visitor',
                              style: TextStyle(
                                fontSize: 11,
                                color: NabihTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Faculty / Staff toggle (only for @uqu.edu.sa non-student)
                    if (_showUniRoleToggle(_emailController.text.trim()) && !_otpSent) ...
                      [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Are you Faculty or Staff?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: NabihTheme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _uniRoleChoice = 'faculty';
                                  _detectRole(_emailController.text.trim());
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _uniRoleChoice == 'faculty'
                                        ? NabihTheme.primary
                                        : NabihTheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: NabihTheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.school_rounded,
                                        size: 18,
                                        color: _uniRoleChoice == 'faculty'
                                            ? Colors.white
                                            : NabihTheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Faculty',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _uniRoleChoice == 'faculty'
                                              ? Colors.white
                                              : NabihTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _uniRoleChoice = 'staff';
                                  _detectRole(_emailController.text.trim());
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _uniRoleChoice == 'staff'
                                        ? NabihTheme.primary
                                        : NabihTheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: NabihTheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.badge_rounded,
                                        size: 18,
                                        color: _uniRoleChoice == 'staff'
                                            ? Colors.white
                                            : NabihTheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Staff',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _uniRoleChoice == 'staff'
                                              ? Colors.white
                                              : NabihTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_otpSent,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _lang.tr('password'),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.length < 6 ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_otpSent,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: _lang.tr('phone'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: NabihTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 18,
                              color: NabihTheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: NabihTheme.error,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Step 1: Sign Up button
                    if (!_otpSent)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_lang.tr('send_otp')),
                        ),
                      )

                    // Step 2: OTP verification
                    else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: NabihTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 18, color: NabihTheme.success),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'A verification code has been sent to your email.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: NabihTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _verifyAndRegister(),
                        decoration: InputDecoration(
                          labelText: _lang.tr('otp_hint'),
                          prefixIcon: const Icon(Icons.security),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyAndRegister,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_lang.tr('verify_otp')),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Resend OTP with countdown
                      _resendCountdown > 0
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.timer_outlined,
                                      size: 16,
                                      color: NabihTheme.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Resend code in ${(_resendCountdown ~/ 60).toString().padLeft(2, '0')}:${(_resendCountdown % 60).toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: NabihTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : TextButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isLoading = true;
                                        _errorMessage = null;
                                      });
                                      try {
                                        await AuthService.sendOtp(
                                            email: _emailController.text
                                                .trim());
                                        _startCountdown();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'New code sent to your email'),
                                              backgroundColor:
                                                  NabihTheme.success,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          setState(() =>
                                              _errorMessage = e.toString());
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(
                                              () => _isLoading = false);
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.refresh,
                                  size: 16, color: NabihTheme.primary),
                              label: const Text(
                                'Resend Code',
                                style: TextStyle(color: NabihTheme.primary),
                              ),
                            ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _otpSent = false;
                                  _otpController.clear();
                                  _errorMessage = null;
                                });
                              },
                        child: const Text('Go back and edit details'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}

// ─── Slide-down phone-style OTP banner ───────────────────────────────────────
class _OtpBanner extends StatefulWidget {
  final String otp;
  final VoidCallback onDismiss;
  const _OtpBanner({required this.otp, required this.onDismiss});

  @override
  State<_OtpBanner> createState() => _OtpBannerState();
}

class _OtpBannerState extends State<_OtpBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: NabihTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: NabihTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Verification Code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your OTP is  ${widget.otp}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 6,
                              color: NabihTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Enter this code to complete registration',
                            style: TextStyle(
                              fontSize: 11,
                              color: NabihTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _dismiss,
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
}
