import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_l10n.dart';
import '../data/auth_flow_args.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/auth_service.dart';
import '../services/local_notification_service.dart';
import '../services/pin_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _ctrl = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());

  bool _verifying = false;
  bool _resending = false;
  int  _attempts  = 0;
  String? _error;

  SignupVerificationArgs? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args ??= ModalRoute.of(context)?.settings.arguments as SignupVerificationArgs?;
  }

  @override
  void dispose() {
    for (final c in _ctrl)  { c.dispose(); }
    for (final f in _focus) { f.dispose(); }
    super.dispose();
  }

  String get _pin => _ctrl.map((c) => c.text).join();

  void _onChanged(String value, int i) {
    if (value.isNotEmpty && i < 5) _focus[i + 1].requestFocus();
    if (_pin.length == 6) _verify();
  }

  void _onKey(KeyEvent e, int i) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrl[i].text.isEmpty &&
        i > 0) {
      _focus[i - 1].requestFocus();
    }
  }

  void _clearBoxes() {
    for (final c in _ctrl) { c.clear(); }
    _focus.first.requestFocus();
    setState(() => _error = null);
  }

  Future<void> _verify() async {
    final args = _args;
    if (args == null || _pin.length < 6) return;
    setState(() { _verifying = true; _error = null; });
    try {
      final ok = PinService.instance.verifyPin(_pin);
      if (!ok) {
        _attempts++;
        final t = l10n(context);
        setState(() {
          _error = _attempts >= 3 ? t.otpMaxAttempts : t.otpAttemptsLeft(3 - _attempts);
        });
        _clearBoxes();
        return;
      }

      // Sign in to get a session so the profile upsert passes RLS
      try {
        await AuthService.instance.signIn(
          email: args.email,
          password: args.password,
        );
      } catch (_) {
        // session unavailable (e.g. email confirmation still pending) — continue
      }

      try {
        await ProfileService.instance.upsertProfile(
          id: args.userId,
          fullName: args.fullName,
          email: args.email,
          role: args.role.dbValue,
          universityId: args.universityId,
        );
      } catch (_) {
        // profile will be created on next login via ensureProfileForCurrentUser
      }

      setActiveSessionProfile(SessionProfile(
        name: args.fullName,
        email: args.email,
        universityId: args.universityId,
        role: args.role,
      ));

      await LocalNotificationService.instance.cancelPin();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        args.role.homeRoute,
        (r) => false,
        arguments: args.role,
      );
    } catch (_) {
      setState(() => _error = l10n(context).somethingWrong);
      _clearBoxes();
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_args == null) return;
    setState(() { _resending = true; _error = null; _attempts = 0; });
    try {
      final pin = PinService.instance.createPin();
      await LocalNotificationService.instance.showPin(pin);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n(context).codeSent)),
      );
      _clearBoxes();
    } catch (_) {
      if (mounted) setState(() => _error = l10n(context).somethingWrong);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageController.isArabic,
      builder: (_, __, ___) {
        final args = _args;
        if (args == null) return _expiredView(context);

        final t = l10n(context);
        return AppScaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BrandHeader(
                subtitle: t.otpHero,
                trailing: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(height: 28),

              // ── Hero card ───────────────────────────────────────────
              SurfaceCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D3533), Color(0xFF0F5B57), Color(0xFF1A8A84)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AccentPill(label: t.confirmIdentity, icon: Icons.mark_email_read_outlined, filled: true),
                  const SizedBox(height: 16),
                  Text(
                    t.otpHero,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.sand),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t.otpSentTo(args.email),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Input card ──────────────────────────────────────────
              SurfaceCard(
                child: Column(children: [

                  // Email hint banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.mail_outline_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.otpHint,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 28),

                  // 6 digit boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) => _OtpBox(
                      controller: _ctrl[i],
                      focusNode: _focus[i],
                      onChanged: (v) => _onChanged(v, i),
                      onKey: (e) => _onKey(e, i),
                      hasError: _error != null,
                    )),
                  ),
                  const SizedBox(height: 20),

                  // Error row
                  if (_error != null) ...[
                    Row(children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 14))),
                    ]),
                    const SizedBox(height: 16),
                  ],

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_verifying || _pin.length < 6) ? null : _verify,
                      icon: _verifying
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.background))
                          : const Icon(Icons.check_circle_outline_rounded),
                      label: Text(_verifying ? t.verifying : t.verifyCode),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Resend button
                  Center(
                    child: TextButton.icon(
                      onPressed: (_resending || _verifying) ? null : _resend,
                      icon: _resending
                          ? const SizedBox(width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                          : const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(t.resendCode),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _expiredView(BuildContext context) {
    final t = l10n(context);
    return AppScaffold(
      body: Center(
        child: SurfaceCard(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.mark_email_unread_outlined, color: AppColors.primary, size: 42),
            const SizedBox(height: 14),
            Text(t.sessionExpired, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
              child: Text(t.goRegister),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Individual OTP digit box ──────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKey;
  final bool hasError;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKey,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKey,
      child: SizedBox(
        width: 48,
        height: 58,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: hasError ? AppColors.danger : AppColors.ink,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? AppColors.danger : AppColors.line,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? AppColors.danger : AppColors.primary,
                width: 2,
              ),
            ),
            fillColor: AppColors.mist,
            filled: true,
          ),
        ),
      ),
    );
  }
}
