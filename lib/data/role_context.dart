import 'package:flutter/material.dart';
import 'app_content.dart';
import 'language_controller.dart';

enum UserRole { student, faculty, admin, visitor }

const authRoles = [UserRole.student, UserRole.faculty, UserRole.admin];

class SessionProfile {
  final String name;
  final String email;
  final String universityId;
  final UserRole role;

  const SessionProfile({
    required this.name,
    required this.email,
    required this.universityId,
    required this.role,
  });
}

SessionProfile? activeSessionProfile;

void setActiveSessionProfile(SessionProfile profile) {
  activeSessionProfile = profile;
}

void clearActiveSessionProfile() {
  activeSessionProfile = null;
}

extension UserRoleDetails on UserRole {
  String get dbValue {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.admin:
        return 'University Admin';
      case UserRole.visitor:
        return 'Visitor';
    }
  }

  String get label {
    switch (this) {
      case UserRole.student:
        return LanguageController.text('Student', 'طالب');
      case UserRole.faculty:
        return LanguageController.text('Faculty', 'عضو هيئة تدريس');
      case UserRole.admin:
        return LanguageController.text('University Admin', 'إدارة الجامعة');
      case UserRole.visitor:
        return LanguageController.text('Visitor', 'زائر');
    }
  }

  String get homeRoute {
    switch (this) {
      case UserRole.student:
        return '/student-home';
      case UserRole.faculty:
        return '/faculty-home';
      case UserRole.admin:
        return '/admin-home';
      case UserRole.visitor:
        return '/visitor-home';
    }
  }

  String get workspaceLabel {
    switch (this) {
      case UserRole.student:
        return LanguageController.text('Student workspace', 'مساحة الطالب');
      case UserRole.faculty:
        return LanguageController.text('Faculty workspace', 'مساحة عضو هيئة التدريس');
      case UserRole.admin:
        return LanguageController.text('University Admin workspace', 'مساحة إدارة الجامعة');
      case UserRole.visitor:
        return LanguageController.text('Visitor assistant', 'مساعد الزائر');
    }
  }
}

class RoleProfile {
  final String name;
  final String subtitle;
  final IconData icon;
  const RoleProfile({required this.name, required this.subtitle, required this.icon});
}

UserRole userRoleFromValue(Object? value, {UserRole fallback = UserRole.student}) {
  if (value is UserRole) {
    return value;
  }
  final text = value?.toString().toLowerCase().trim() ?? '';
  if (text.contains('faculty') || text.contains('هيئة')) {
    return UserRole.faculty;
  }
  if (text.contains('admin') || text.contains('إدارة') || text.contains('ادارة')) {
    return UserRole.admin;
  }
  if (text.contains('visitor') || text.contains('guest') || text.contains('زائر')) {
    return UserRole.visitor;
  }
  if (text.contains('student') || text.contains('طالب')) {
    return UserRole.student;
  }
  return fallback;
}

UserRole currentUserRole(BuildContext context, {UserRole fallback = UserRole.student}) {
  final fromRoute = ModalRoute.of(context)?.settings.arguments;
  if (fromRoute != null) {
    return userRoleFromValue(fromRoute, fallback: fallback);
  }
  return activeSessionProfile?.role ?? fallback;
}

RoleProfile profileForRole(UserRole role) {
  final session = activeSessionProfile;
  if (session != null && session.role == role) {
    return RoleProfile(
      name: session.name,
      subtitle: '${role.label} • ${session.email}',
      icon: iconForRole(role),
    );
  }
  switch (role) {
    case UserRole.faculty:
      return RoleProfile(
        name: LanguageController.text('Faculty Member', 'عضو هيئة تدريس'),
        subtitle: LanguageController.text('Faculty • Umm Al Qura University', 'عضو هيئة تدريس • جامعة أم القرى'),
        icon: Icons.badge_outlined,
      );
    case UserRole.admin:
      return RoleProfile(
        name: LanguageController.text('University Admin', 'إدارة الجامعة'),
        subtitle: LanguageController.text('Campus communications and operations', 'اتصالات وعمليات الحرم الجامعي'),
        icon: Icons.admin_panel_settings_outlined,
      );
    case UserRole.visitor:
      return RoleProfile(
        name: LanguageController.text('Campus Visitor', 'زائر الحرم الجامعي'),
        subtitle: LanguageController.text('Visitor • Public access', 'زائر • وصول عام'),
        icon: Icons.travel_explore_outlined,
      );
    case UserRole.student:
      return RoleProfile(
        name: LanguageController.text('Student User', 'مستخدم طالب'),
        subtitle: LanguageController.text('Student • Umm Al Qura University', 'طالب • جامعة أم القرى'),
        icon: Icons.person_outline_rounded,
      );
  }
}

IconData iconForRole(UserRole role) {
  switch (role) {
    case UserRole.student:
      return Icons.person_outline_rounded;
    case UserRole.faculty:
      return Icons.badge_outlined;
    case UserRole.admin:
      return Icons.admin_panel_settings_outlined;
    case UserRole.visitor:
      return Icons.travel_explore_outlined;
  }
}

String firstNameForRole(UserRole role) {
  final session = activeSessionProfile;
  if (session != null && session.role == role && session.name.trim().isNotEmpty) {
    return session.name.trim().split(' ').first;
  }
  switch (role) {
    case UserRole.student:
      return LanguageController.text('Student', 'الطالب');
    case UserRole.faculty:
      return LanguageController.text('Faculty', 'الدكتور');
    case UserRole.admin:
      return LanguageController.text('Admin', 'الإدارة');
    case UserRole.visitor:
      return LanguageController.text('Visitor', 'الزائر');
  }
}

List<ScheduleItem> scheduleForRole(UserRole role) {
  return role == UserRole.faculty ? facultySchedule : studentSchedule;
}

String scheduleTitleForRole(UserRole role) {
  return role == UserRole.faculty ? LanguageController.text('Teaching Week', 'أسبوع التدريس') : LanguageController.text('This Week', 'هذا الأسبوع');
}

String scheduleIntroForRole(UserRole role) {
  return role == UserRole.faculty
      ? LanguageController.text(
          'Faculty can review lectures, labs, and office hours with clear calendar actions for the week.',
          'يمكن لعضو هيئة التدريس مراجعة المحاضرات والمعامل والساعات المكتبية مع إجراءات واضحة للأسبوع.',
        )
      : LanguageController.text(
          'Students can review schedule items and keep class timing visible from one place.',
          'يمكن للطالب مراجعة عناصر الجدول وإبقاء أوقات المحاضرات واضحة في مكان واحد.',
        );
}

String schedulePrimaryActionForRole(UserRole role) {
  return role == UserRole.faculty ? LanguageController.text('Sync Teaching Calendar', 'مزامنة تقويم التدريس') : LanguageController.text('Add to Calendar', 'أضف إلى التقويم');
}

String scheduleSecondaryActionForRole(UserRole role) {
  return role == UserRole.faculty ? LanguageController.text('Add Office Hour', 'إضافة ساعة مكتبية') : LanguageController.text('Add Manual Class', 'إضافة محاضرة يدويًا');
}

List<AlertItem> alertsForRole(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return [
        AlertItem(
          title: LanguageController.text('Section 201 Reminder', 'تذكير شعبة 201'),
          body: LanguageController.text('Two students submitted late excuse requests for review before the next lecture.', 'قدّم طالبان طلبات أعذار متأخرة للمراجعة قبل المحاضرة القادمة.'),
          time: LanguageController.text('12 min ago', 'منذ 12 دقيقة'),
          icon: Icons.groups_outlined,
          tone: const Color(0xFF26476D),
        ),
        ...alerts,
      ];
    case UserRole.admin:
      return [
        AlertItem(
          title: LanguageController.text('Announcement Reach Update', 'تحديث وصول الإعلان'),
          body: LanguageController.text('The latest university-wide notice has reached most active app users.', 'وصل آخر إشعار على مستوى الجامعة إلى معظم مستخدمي التطبيق النشطين.'),
          time: LanguageController.text('15 min ago', 'منذ 15 دقيقة'),
          icon: Icons.campaign_outlined,
          tone: const Color(0xFFB38A3D),
        ),
        ...alerts,
      ];
    case UserRole.visitor:
      return [
        AlertItem(
          title: LanguageController.text('Visitor Gate Guidance', 'إرشادات بوابة الزوار'),
          body: LanguageController.text('Guests are currently directed to Gate 3 for parking and reception access.', 'يتم توجيه الزوار حاليًا إلى البوابة 3 لمواقف السيارات والوصول إلى الاستقبال.'),
          time: LanguageController.text('Now', 'الآن'),
          icon: Icons.travel_explore_outlined,
          tone: const Color(0xFF0F5B57),
        ),
        AlertItem(
          title: LanguageController.text('Public Event Tonight', 'فعالية عامة الليلة'),
          body: LanguageController.text('The Innovation Forum is open to registered visitors in the main auditorium.', 'منتدى الابتكار مفتوح للزوار المسجلين في القاعة الرئيسية.'),
          time: LanguageController.text('Today', 'اليوم'),
          icon: Icons.event_outlined,
          tone: const Color(0xFF26476D),
        ),
      ];
    case UserRole.student:
      return alerts;
  }
}
