import 'package:flutter/material.dart';
import 'language_controller.dart';

AppL10n l10n(BuildContext context) => AppL10n(LanguageController.isArabic.value);

class AppL10n {
  final bool _ar;
  const AppL10n(this._ar);

  bool get isAr => _ar;

  String _s(String en, String ar) => _ar ? ar : en;

  // ── Nav labels ───────────────────────────────────────────────────────────────
  String navLabel(String key) {
    switch (key) {
      case 'Home':     return _s('Home',     'الرئيسية');
      case 'Schedule': return _s('Schedule', 'الجدول');
      case 'Alerts':   return _s('Alerts',   'التنبيهات');
      case 'Profile':  return _s('Profile',  'الملف');
      case 'Notify':   return _s('Notify',   'إشعار');
      case 'Publish':  return _s('Publish',  'نشر');
      case 'Events':   return _s('Events',   'الفعاليات');
      case 'Campus':   return _s('Campus',   'الجامعة');
      case 'Updates':  return _s('Updates',  'التحديثات');
      default:         return key;
    }
  }

  // ── App-wide ─────────────────────────────────────────────────────────────────
  String get uquName       => _s('Umm Al Qura University', 'جامعة أم القرى');
  String get splashSubtitle => _s('Smart University Assistant', 'المساعد الجامعي الذكي');

  // ── Role labels ──────────────────────────────────────────────────────────────
  String get roleStudent => _s('Student',          'طالب');
  String get roleFaculty => _s('Faculty',          'عضو هيئة تدريس');
  String get roleAdmin   => _s('University Admin', 'إدارة الجامعة');
  String get roleVisitor => _s('Visitor',          'زائر');

  String roleLabel(String raw) {
    if (raw.contains('Faculty') || raw.contains('هيئة') || raw.contains('تدريس')) return roleFaculty;
    if (raw.contains('Admin')   || raw.contains('إدارة') || raw.contains('ادارة')) return roleAdmin;
    if (raw.contains('Visitor') || raw.contains('زائر')  || raw.contains('ضيف'))  return roleVisitor;
    return roleStudent;
  }

  // ── Common actions ───────────────────────────────────────────────────────────
  String get login             => _s('Login',               'تسجيل الدخول');
  String get createAccount     => _s('Create Account',      'إنشاء حساب');
  String get continueAsVisitor => _s('Continue as Visitor', 'المتابعة كزائر');
  String get smartAssistant    => _s('Smart Assistant',     'المساعد الذكي');
  String get logOut            => _s('Log Out',             'تسجيل الخروج');

  // ── Auth screen ──────────────────────────────────────────────────────────────
  String get welcomeBack      => _s('Welcome back.',           'مرحبًا بعودتك.');
  String get loginInstruction => _s(
    'Use your university email and password to sign in.',
    'استخدم بريدك الجامعي وكلمة المرور لتسجيل الدخول.',
  );
  String get universityEmail  => _s('University Email',  'البريد الجامعي');
  String get emailHint        => _s('name@uqu.edu.sa',   'الاسم@uqu.edu.sa');
  String get password         => _s('Password',          'كلمة المرور');
  String get forgotPassword   => _s('Forgot password?',  'نسيت كلمة المرور؟');
  String get signingIn        => _s('Signing in…',       'جارٍ تسجيل الدخول…');

  // ── Register ─────────────────────────────────────────────────────────────────
  String get registerTitle      => _s('Create your NABIH account.',    'أنشئ حسابك في NABIH.');
  String get registerBody       => _s(
    'Use your Umm Al Qura University email. Your workspace is detected automatically.',
    'استخدم بريد جامعة أم القرى، وستُحدَّد مساحة العمل تلقائيًا.',
  );
  String get fullName           => _s('Full Name',             'الاسم الكامل');
  String get confirmPassword    => _s('Confirm Password',      'تأكيد كلمة المرور');
  String get creatingAccount    => _s('Creating account…',     'جارٍ إنشاء الحساب…');
  String get alreadyHaveAccount => _s('Already have an account? Login', 'لديك حساب؟ سجل الدخول');

  // ── Visitor tab ──────────────────────────────────────────────────────────────
  String get visitorHero           => _s('Welcome to Umm Al Qura University.', 'مرحبًا بك في جامعة أم القرى.');
  String get visitorBody           => _s(
    'Access campus wayfinding, public information, and open events without registration.',
    'تصفح خرائط الجامعة والمعلومات العامة والفعاليات المفتوحة دون تسجيل.',
  );
  String get openCampusNavigation  => _s('Open Campus Navigation', 'فتح خرائط الجامعة');
  String get openCampusEvents      => _s('Open campus events',     'فعاليات الجامعة المفتوحة');
  String get guestTools            => _s('Guest Tools',             'أدوات الزائر');
  String get publicEventsDirection => _s('Public events direction', 'توجيه الفعاليات العامة');
  String get guidedVisitorRoutes   => _s('Guided visitor routes',   'مسارات الزائر الموجهة');
  String get visitorNote           => _s(
    'Visitor access does not require registration.',
    'لا يتطلب وصول الزائر تسجيلاً.',
  );

  // ── OTP / Email verification ─────────────────────────────────────────────────
  String get otpHero         => _s('Enter the verification code',          'أدخل رمز التحقق');
  String get otpHint         => _s('Pull down notifications to see your code', 'اسحب القائمة العلوية لعرض الرمز');
  String get verifyCode      => _s('Verify Code',                          'تحقق من الرمز');
  String get verifying       => _s('Verifying…',                           'جارٍ التحقق…');
  String get resendCode      => _s('Resend code',                          'إرسال رمز جديد');
  String get codeSent        => _s('A new code was sent to your email',    'تم إرسال رمز جديد إلى بريدك');
  String get sessionExpired  => _s('Verification session expired.',        'انتهت جلسة التحقق.');
  String get goRegister      => _s('Create account',                       'إنشاء حساب');
  String get confirmIdentity => _s('Confirm Identity',                     'تأكيد الهوية');
  String otpSentTo(String email) => _s('A 6-digit code was sent to $email.\nValid for 15 minutes.', 'تم إرسال رمز من 6 أرقام إلى $email.\nصالح لمدة 15 دقيقة.');
  String otpAttemptsLeft(int n)  => _s('Wrong code. $n attempt${n == 1 ? "" : "s"} left.', 'رمز غير صحيح. المحاولات المتبقية: $n');
  String get otpMaxAttempts     => _s('Too many attempts. Request a new code.', 'تم تجاوز عدد المحاولات. اطلب رمزاً جديداً.');

  // ── Validation ───────────────────────────────────────────────────────────────
  String get universityId         => _s('Student ID',                             'الرقم الجامعي');
  String get enterUniversityId    => _s('Enter your student ID',                  'أدخل رقمك الجامعي');
  String get universityIdMin      => _s('ID must be at least 6 digits',           'الرقم الجامعي 6 أرقام على الأقل');
  String get enterEmail           => _s('Enter your university email',            'أدخل بريدك الجامعي');
  String get validEmail           => _s('Enter a valid email address',            'أدخل بريدًا صحيحًا');
  String get uquEmailRequired     => _s('Use your Umm Al Qura University email',  'استخدم بريد جامعة أم القرى');
  String get enterPassword        => _s('Enter your password',                    'أدخل كلمة المرور');
  String get passwordMin          => _s('Password must be at least 8 characters', 'كلمة المرور 8 أحرف على الأقل');
  String get enterFullName        => _s('Enter your full name',                   'أدخل اسمك الكامل');
  String get enterPasswordField   => _s('Enter a password',                       'أدخل كلمة مرور');
  String get confirmPasswordField => _s('Confirm your password',                  'أكد كلمة المرور');
  String get passwordsNoMatch     => _s('Passwords do not match',                 'كلمتا المرور غير متطابقتين');
  String get somethingWrong       => _s('Something went wrong',                   'حدث خطأ ما');
}
