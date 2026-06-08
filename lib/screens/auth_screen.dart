import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/account_rules.dart';
import '../data/app_l10n.dart';
import '../data/auth_flow_args.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/auth_service.dart';
import '../services/local_notification_service.dart';
import '../services/pin_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageController.isArabic,
      builder: (_, isAr, __) {
        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              // ── header ────────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF152B44),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                              padding: EdgeInsets.zero,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => LanguageController.toggle(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  isAr ? 'English' : 'العربية',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Image.asset('assets/branding/nabih_mark.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('NABIH', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            Text(
                              isAr ? 'جامعة أم القرى' : 'Umm Al Qura University',
                              style: TextStyle(color: Colors.white.withValues(alpha: .65), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ]),
                        ]),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TabBar(
                            controller: _tab,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: Colors.white.withValues(alpha: .7),
                            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            tabs: [
                              Tab(text: isAr ? 'دخول' : 'Sign In'),
                              Tab(text: isAr ? 'حساب جديد' : 'Sign Up'),
                              Tab(text: isAr ? 'زائر' : 'Visitor'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              // ── tab views ─────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: const [
                    _SignInTab(),
                    _SignUpTab(),
                    _VisitorTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SIGN IN TAB
// ══════════════════════════════════════════════════════════════════
class _SignInTab extends StatefulWidget {
  const _SignInTab();

  @override
  State<_SignInTab> createState() => _SignInTabState();
}

class _SignInTabState extends State<_SignInTab> {
  final _form  = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _hide = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      final res = await AuthService.instance.signIn(
        email: _email.text.trim(),
        password: _pass.text,
      );
      if (!mounted) return;
      final user = res.user!;
      final data = await ProfileService.instance.getProfile(user.id);
      if (!mounted) return;
      if (data == null) { _err('Profile not found'); return; }
      final role = userRoleFromValue(data['role'], fallback: UserRole.student);
      setActiveSessionProfile(SessionProfile(
        name: data['full_name'] as String? ?? 'User',
        email: data['email'] as String? ?? user.email ?? _email.text.trim(),
        universityId: data['university_id'] as String? ?? '',
        role: role,
      ));
      Navigator.pushReplacementNamed(context, role.homeRoute, arguments: role);
    } on AuthException catch (e) {
      _err(e.message);
    } catch (_) {
      _err(l10n(context).somethingWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageController.isArabic,
      builder: (_, __, ___) {
        final t = l10n(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.welcomeBack, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(t.loginInstruction, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: t.universityEmail,
                    hintText: t.emailHint,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return t.enterEmail;
                    if (!v.contains('@')) return t.validEmail;
                    if (!v.trim().endsWith('@uqu.edu.sa')) return t.uquEmailRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pass,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    labelText: t.password,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? t.enterPassword : null,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: Text(t.forgotPassword, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    child: _busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(t.login),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SIGN UP TAB
// ══════════════════════════════════════════════════════════════════
class _SignUpTab extends StatefulWidget {
  const _SignUpTab();

  @override
  State<_SignUpTab> createState() => _SignUpTabState();
}

class _SignUpTabState extends State<_SignUpTab> {
  final _form   = GlobalKey<FormState>();
  final _name   = TextEditingController();
  final _email  = TextEditingController();
  final _uniId  = TextEditingController();
  final _pass   = TextEditingController();
  final _conf   = TextEditingController();
  bool _hide     = true;
  bool _hideConf = true;
  bool _busy     = false;
  UserRole _detectedRole = UserRole.student;
  bool _validDomain = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final email = cleanEmail(_email.text);
    final valid = isAcceptedRegistrationEmail(email);
    final role  = valid ? roleFromRegistrationEmail(email) : UserRole.student;
    if (valid != _validDomain || role != _detectedRole) {
      setState(() { _validDomain = valid; _detectedRole = role; });
    }
  }

  @override
  void dispose() {
    _email.removeListener(_onEmailChanged);
    _name.dispose(); _email.dispose(); _uniId.dispose(); _pass.dispose(); _conf.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    if (!_validDomain) {
      _err(l10n(context).uquEmailRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      final email      = cleanEmail(_email.text);
      final name       = _name.text.trim();
      final password   = _pass.text;
      final role       = roleFromRegistrationEmail(email);
      final universityId = role == UserRole.student ? _uniId.text.trim() : '';

      final res = await AuthService.instance.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'role': role.dbValue, 'university_id': universityId},
      );
      if (!mounted) return;

      final user = res.user;
      if (user == null) throw const AuthException('تعذّر إنشاء الحساب.');

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

      Navigator.pushNamed(context, '/verify-email',
        arguments: SignupVerificationArgs(
          userId: user.id,
          email: email,
          password: password,
          fullName: name,
          universityId: universityId,
          role: role,
        ),
      );
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('rate') || msg.contains('limit') || msg.contains('too many')) {
        _err(LanguageController.text(
          'Email rate limit reached. Wait a few minutes and try again.',
          'تم تجاوز حد الإرسال. انتظر بضع دقائق وأعد المحاولة.',
        ));
      } else if (msg.contains('already') || msg.contains('registered') || msg.contains('exists')) {
        _err(LanguageController.text(
          'This email is already registered. Try signing in.',
          'البريد مسجل مسبقًا. جرب تسجيل الدخول.',
        ));
      } else {
        _err(e.message);
      }
    } catch (_) {
      _err(l10n(context).somethingWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageController.isArabic,
      builder: (_, __, ___) {
        final t = l10n(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.registerTitle, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(t.registerBody, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: t.fullName, prefixIcon: const Icon(Icons.person_outline_rounded)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? t.enterFullName : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: t.universityEmail, hintText: t.emailHint, prefixIcon: const Icon(Icons.email_outlined)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return t.enterEmail;
                    if (!v.trim().contains('@')) return t.validEmail;
                    if (!isAcceptedRegistrationEmail(cleanEmail(v))) return t.uquEmailRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DetectedRoleCard(role: _detectedRole, validDomain: _validDomain),
                if (_validDomain && _detectedRole == UserRole.student) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _uniId,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: t.universityId,
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    validator: (v) {
                      if (_detectedRole != UserRole.student) return null;
                      if (v == null || v.trim().isEmpty) return t.enterUniversityId;
                      if (v.trim().length < 6) return t.universityIdMin;
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _pass,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    labelText: t.password,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return t.enterPasswordField;
                    if (v.length < 8) return t.passwordMin;
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _conf,
                  obscureText: _hideConf,
                  decoration: InputDecoration(
                    labelText: t.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_hideConf ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _hideConf = !_hideConf),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return t.confirmPasswordField;
                    if (v != _pass.text) return t.passwordsNoMatch;
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    child: _busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(t.createAccount),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _busy ? null : () => Navigator.pushReplacementNamed(context, '/auth'),
                    child: Text(t.alreadyHaveAccount),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetectedRoleCard extends StatelessWidget {
  final UserRole role;
  final bool validDomain;
  const _DetectedRoleCard({required this.role, required this.validDomain});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageController.isArabic,
      builder: (_, isAr, __) {
        final color = validDomain ? AppColors.primary : AppColors.secondary;
        final label = validDomain
            ? (isAr ? 'المساحة المحددة: ${role.label}' : 'Detected workspace: ${role.label}')
            : (isAr ? 'استخدم @uqu.edu.sa لتحديد المساحة' : 'Use @uqu.edu.sa to detect your workspace');
        final body = validDomain
            ? (isAr
                ? 'بريد الطالب يبدأ بحرف s، وبقية بريد جامعة أم القرى يستمر كعضو هيئة تدريس.'
                : 'Student emails start with s. Other UQU emails continue as Faculty.')
            : (isAr ? 'يُقبل بريد جامعة أم القرى فقط.' : 'Only Umm Al Qura University email is accepted.');
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
                    Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(body, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// VISITOR TAB
// ══════════════════════════════════════════════════════════════════
class _VisitorTab extends StatelessWidget {
  const _VisitorTab();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageController.isArabic,
      builder: (_, __, ___) {
        final t = l10n(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.travel_explore_rounded, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 24),
              Text(t.visitorHero, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(t.visitorBody, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              _VisitorFeature(icon: Icons.map_outlined,       title: t.openCampusNavigation, subtitle: t.guidedVisitorRoutes),
              const SizedBox(height: 12),
              _VisitorFeature(icon: Icons.event_outlined,     title: t.openCampusEvents,     subtitle: t.publicEventsDirection),
              const SizedBox(height: 12),
              _VisitorFeature(icon: Icons.smart_toy_outlined, title: t.smartAssistant,       subtitle: t.guestTools),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setActiveSessionProfile(const SessionProfile(
                      name: 'Visitor', email: '', universityId: '', role: UserRole.visitor,
                    ));
                    Navigator.pushReplacementNamed(context, '/visitor-home', arguments: UserRole.visitor);
                  },
                  icon: const Icon(Icons.travel_explore_rounded),
                  label: Text(t.continueAsVisitor),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(t.visitorNote, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VisitorFeature extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _VisitorFeature({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ]),
          ),
        ],
      ),
    );
  }
}
