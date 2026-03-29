import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._();
  factory LanguageService() => _instance;
  LanguageService._();

  static LanguageService get instance => _instance;

  bool _isArabic = false;
  bool get isArabic => _isArabic;
  String get langCode => _isArabic ? 'ar' : 'en';

  void toggle() {
    _isArabic = !_isArabic;
    notifyListeners();
  }

  void setArabic(bool value) {
    if (_isArabic != value) {
      _isArabic = value;
      notifyListeners();
    }
  }

  /// Get a translated string
  String tr(String key) {
    final map = _isArabic ? _ar : _en;
    return map[key] ?? key;
  }

  // ── English strings ──
  static const _en = <String, String>{
    // General
    'app_name': 'NABIH',
    'coming_soon': 'Coming Soon',
    'coming_soon_msg': 'Coming Soon! This feature is under development.',
    'stay_tuned': 'Stay tuned for updates!',
    'feature_under_dev': 'feature is under development.',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'error': 'Error',
    'success': 'Success',
    'loading': 'Loading...',
    'soon': 'Soon',
    'active': 'Active',

    // Splash
    'splash_title': 'NABIH',
    'splash_subtitle': 'Smart University Assistant',
    'splash_uqu': 'Umm Al Qura University',
    'get_started': 'Get Started',

    // Login
    'login': 'Login',
    'login_title': 'Welcome Back',
    'login_subtitle': 'Sign in to your NABIH account',
    'email': 'Email',
    'email_hint': 'Enter your email',
    'password': 'Password',
    'password_hint': 'Enter your password',
    'sign_in': 'Sign In',
    'no_account': "Don't have an account? ",
    'register': 'Register',
    'login_failed': 'Login failed',

    // Register
    'create_account': 'Create Account',
    'register_subtitle': 'Join the NABIH smart assistant',
    'full_name': 'Full Name',
    'name_hint': 'Enter your full name',
    'phone': 'Phone (optional)',
    'phone_hint': 'e.g. 05xxxxxxxx',
    'send_otp': 'Send Verification Code',
    'verify_otp': 'Verify & Complete',
    'otp_code': 'Verification Code',
    'otp_hint': 'Enter 6-digit code',
    'otp_sent': 'Verification code sent to your email!',
    'otp_check_email': 'Check your email for the code',
    'resend_in': 'Resend in',
    'resend_otp': 'Resend Code',
    'have_account': 'Already have an account? ',
    'role_detected': 'Role detected',
    'student': 'Student',
    'faculty': 'Faculty',
    'staff': 'Staff',
    'visitor': 'Visitor',
    'choose_role': 'Choose your role:',
    'password_min': 'Password must be at least 6 characters',
    'email_required': 'Email is required',
    'name_required': 'Name is required',

    // Bottom Nav
    'nav_home': 'Home',
    'nav_navigate': 'Navigate',
    'nav_events': 'Events',
    'nav_alerts': 'Alerts',
    'nav_profile': 'Profile',

    // Dashboard
    'hello': 'Hello',
    'navigate': 'Navigate',
    'schedule': 'Schedule',
    'gpa_calc': 'GPA Calc',
    'announce': 'Announce',
    'features': 'Features',
    'feat_reg_login': 'Registration & Login',
    'feat_reg_login_desc': 'OTP email verification with role detection',
    'feat_navigation': 'Campus Navigation',
    'feat_navigation_desc': 'Visual wayfinding to any POI',
    'feat_profile': 'User Profile',
    'feat_profile_desc': 'View and edit your profile information',
    'feat_events': 'Events & Activities',
    'feat_events_desc': 'Discover and manage campus events',
    'feat_announcements': 'Announcements',
    'feat_announcements_desc': 'University-wide announcements',
    'feat_schedule': 'Class Schedule',
    'feat_schedule_desc': 'Manage your weekly timetable',
    'feat_gpa': 'GPA Calculator',
    'feat_gpa_desc': 'Calculate your semester GPA',
    'feat_notifications': 'Notifications',
    'feat_notifications_desc': 'Faculty-to-student messaging',

    // Navigation
    'campus_navigation': 'Campus Navigation',
    'help': 'Help',
    'nav_tutorial_title': 'How to Navigate',
    'nav_step1': '1. Select your starting point on the map',
    'nav_step2': '2. Select your destination',
    'nav_step3': '3. Tap "Find Route" to see directions',
    'nav_step4': '4. Follow the highlighted path',
    'nav_step5': '5. Use floor selector to switch between floors',
    'got_it': 'Got it!',

    // Profile
    'profile': 'Profile',
    'edit_profile': 'Edit Profile',
    'department': 'Department',
    'student_id': 'Student ID',
    'quick_access': 'Quick Access',
    'gpa_calculator': 'GPA Calculator',
    'gpa_calc_desc': 'Calculate your semester GPA',
    'my_schedule': 'My Schedule',
    'my_schedule_desc': 'View your class timetable',
    'announcements': 'Announcements',
    'announcements_desc': 'View university announcements',
    'sign_out': 'Sign Out',
    'sign_out_failed': 'Sign out failed',
    'profile_updated': 'Profile updated!',
    'profile_update_failed': 'Failed to update',
    'save_changes': 'Save Changes',
    'name': 'Name',
    'language': 'Language',
    'switch_language': 'Switch Language',
    // AI Chat
    'ai_chat': 'AI Chat',
    'ai_chat_coming_soon': 'AI Chat — Coming Soon! This feature is under development.',
  };

  // ── Arabic strings ──
  static const _ar = <String, String>{
    // General
    'app_name': 'نبيه',
    'coming_soon': 'قريبًا',
    'coming_soon_msg': 'قريبًا! هذه الميزة قيد التطوير.',
    'stay_tuned': 'ترقبوا التحديثات!',
    'feature_under_dev': 'هذه الميزة قيد التطوير.',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'delete': 'حذف',
    'error': 'خطأ',
    'success': 'نجاح',
    'loading': 'جاري التحميل...',
    'soon': 'قريبًا',
    'active': 'مفعّل',

    // Splash
    'splash_title': 'نبيه',
    'splash_subtitle': 'المساعد الجامعي الذكي',
    'splash_uqu': 'جامعة أم القرى',
    'get_started': 'ابدأ الآن',

    // Login
    'login': 'تسجيل الدخول',
    'login_title': 'مرحبًا بعودتك',
    'login_subtitle': 'سجّل الدخول إلى حسابك في نبيه',
    'email': 'البريد الإلكتروني',
    'email_hint': 'أدخل بريدك الإلكتروني',
    'password': 'كلمة المرور',
    'password_hint': 'أدخل كلمة المرور',
    'sign_in': 'تسجيل الدخول',
    'no_account': 'ليس لديك حساب؟ ',
    'register': 'إنشاء حساب',
    'login_failed': 'فشل تسجيل الدخول',

    // Register
    'create_account': 'إنشاء حساب',
    'register_subtitle': 'انضم إلى مساعد نبيه الذكي',
    'full_name': 'الاسم الكامل',
    'name_hint': 'أدخل اسمك الكامل',
    'phone': 'الهاتف (اختياري)',
    'phone_hint': 'مثال: 05xxxxxxxx',
    'send_otp': 'إرسال رمز التحقق',
    'verify_otp': 'تحقق وأكمل',
    'otp_code': 'رمز التحقق',
    'otp_hint': 'أدخل الرمز المكون من 6 أرقام',
    'otp_sent': 'تم إرسال رمز التحقق إلى بريدك!',
    'otp_check_email': 'تحقق من بريدك الإلكتروني',
    'resend_in': 'إعادة الإرسال خلال',
    'resend_otp': 'إعادة إرسال الرمز',
    'have_account': 'لديك حساب بالفعل؟ ',
    'role_detected': 'تم تحديد الدور',
    'student': 'طالب',
    'faculty': 'عضو هيئة تدريس',
    'staff': 'موظف',
    'visitor': 'زائر',
    'choose_role': 'اختر دورك:',
    'password_min': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
    'email_required': 'البريد الإلكتروني مطلوب',
    'name_required': 'الاسم مطلوب',

    // Bottom Nav
    'nav_home': 'الرئيسية',
    'nav_navigate': 'التنقل',
    'nav_events': 'الفعاليات',
    'nav_alerts': 'التنبيهات',
    'nav_profile': 'الملف',

    // Dashboard
    'hello': 'مرحبًا',
    'navigate': 'التنقل',
    'schedule': 'الجدول',
    'gpa_calc': 'المعدل',
    'announce': 'الإعلانات',
    'features': 'الميزات',
    'feat_reg_login': 'التسجيل وتسجيل الدخول',
    'feat_reg_login_desc': 'تحقق عبر البريد مع تحديد الدور تلقائيًا',
    'feat_navigation': 'التنقل في الحرم',
    'feat_navigation_desc': 'إرشاد بصري إلى أي نقطة اهتمام',
    'feat_profile': 'الملف الشخصي',
    'feat_profile_desc': 'عرض وتعديل معلوماتك الشخصية',
    'feat_events': 'الفعاليات والأنشطة',
    'feat_events_desc': 'اكتشف وأدر فعاليات الحرم الجامعي',
    'feat_announcements': 'الإعلانات',
    'feat_announcements_desc': 'إعلانات على مستوى الجامعة',
    'feat_schedule': 'الجدول الدراسي',
    'feat_schedule_desc': 'إدارة جدولك الأسبوعي',
    'feat_gpa': 'حاسبة المعدل',
    'feat_gpa_desc': 'احسب معدلك الفصلي',
    'feat_notifications': 'الإشعارات',
    'feat_notifications_desc': 'رسائل من أعضاء هيئة التدريس للطلاب',

    // Navigation
    'campus_navigation': 'التنقل في الحرم',
    'help': 'مساعدة',
    'nav_tutorial_title': 'كيفية التنقل',
    'nav_step1': '١. حدد نقطة البداية على الخريطة',
    'nav_step2': '٢. حدد وجهتك',
    'nav_step3': '٣. اضغط "ابحث عن المسار" لعرض الاتجاهات',
    'nav_step4': '٤. اتبع المسار المحدد',
    'nav_step5': '٥. استخدم محدد الطوابق للتنقل بين الأدوار',
    'got_it': 'فهمت!',

    // Profile
    'profile': 'الملف الشخصي',
    'edit_profile': 'تعديل الملف',
    'department': 'القسم',
    'student_id': 'الرقم الجامعي',
    'quick_access': 'وصول سريع',
    'gpa_calculator': 'حاسبة المعدل',
    'gpa_calc_desc': 'احسب معدلك الفصلي',
    'my_schedule': 'جدولي',
    'my_schedule_desc': 'عرض جدول محاضراتك',
    'announcements': 'الإعلانات',
    'announcements_desc': 'عرض إعلانات الجامعة',
    'sign_out': 'تسجيل الخروج',
    'sign_out_failed': 'فشل تسجيل الخروج',
    'profile_updated': 'تم تحديث الملف الشخصي!',
    'profile_update_failed': 'فشل التحديث',
    'save_changes': 'حفظ التغييرات',
    'name': 'الاسم',
    'language': 'اللغة',
    'switch_language': 'تغيير اللغة',
    // AI Chat
    'ai_chat': 'المساعد الذكي',
    'ai_chat_coming_soon': 'المساعد الذكي — قريبًا! هذه الميزة قيد التطوير.',
  };
}
