import 'package:flutter/material.dart';
import 'language_controller.dart';

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  const QuickAction({required this.title, required this.subtitle, required this.icon, required this.route});
}

class ScheduleItem {
  final String title;
  final String time;
  final String meta;
  final String place;
  final String days;
  final Color accent;
  const ScheduleItem({required this.title, required this.time, required this.meta, required this.place, this.days = '', required this.accent});
}

class AlertItem {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color tone;
  const AlertItem({required this.title, required this.body, required this.time, required this.icon, required this.tone});
}

List<QuickAction> get studentActions => [
      QuickAction(title: LanguageController.text('Today Schedule', 'جدول اليوم'), subtitle: LanguageController.text('Review classes and labs', 'راجع المحاضرات والمعامل'), icon: Icons.calendar_today_rounded, route: '/schedule'),
      QuickAction(title: LanguageController.text('GPA Calculator', 'حاسبة المعدل'), subtitle: LanguageController.text('Estimate this semester', 'توقع نتائج هذا الفصل'), icon: Icons.calculate_outlined, route: '/gpa'),
      QuickAction(title: LanguageController.text('Interactive Map', 'الخريطة التفاعلية'), subtitle: LanguageController.text('Find halls, rooms, and labs', 'اعثر على القاعات والغرف والمعامل'), icon: Icons.map_outlined, route: '/navigation'),
      QuickAction(title: LanguageController.text('Notifications', 'الإشعارات'), subtitle: LanguageController.text('Announcements and alerts', 'الإعلانات والتنبيهات'), icon: Icons.notifications_none_rounded, route: '/notifications'),
    ];

List<QuickAction> get facultyActions => [
      QuickAction(title: LanguageController.text('Teaching Schedule', 'جدول التدريس'), subtitle: LanguageController.text('Today and upcoming', 'اليوم والقادم'), icon: Icons.event_note_rounded, route: '/schedule'),
      QuickAction(title: LanguageController.text('Send Notification', 'إرسال إشعار'), subtitle: LanguageController.text('Target a section or group', 'استهداف شعبة أو مجموعة'), icon: Icons.campaign_outlined, route: '/faculty-notify'),
      QuickAction(title: LanguageController.text('Interactive Map', 'الخريطة التفاعلية'), subtitle: LanguageController.text('Rooms, labs, and teaching halls', 'الغرف والمعامل وقاعات التدريس'), icon: Icons.map_outlined, route: '/navigation'),
      QuickAction(title: LanguageController.text('Alerts Center', 'مركز التنبيهات'), subtitle: LanguageController.text('Institution updates', 'تحديثات المؤسسة'), icon: Icons.notifications_none_rounded, route: '/notifications'),
    ];

List<QuickAction> get adminActions => [
      QuickAction(title: LanguageController.text('Create Announcement', 'إنشاء إعلان'), subtitle: LanguageController.text('Campus-wide publishing', 'نشر على مستوى الجامعة'), icon: Icons.edit_outlined, route: '/announcement'),
      QuickAction(title: LanguageController.text('Create Event', 'إنشاء فعالية'), subtitle: LanguageController.text('Manage public university events', 'إدارة فعاليات الجامعة العامة'), icon: Icons.event_available_rounded, route: '/admin-event'),
      QuickAction(title: LanguageController.text('Notifications Center', 'مركز الإشعارات'), subtitle: LanguageController.text('Broadcast visibility', 'إدارة الظهور والبث'), icon: Icons.notifications_active_outlined, route: '/notifications'),
      QuickAction(title: LanguageController.text('Interactive Map', 'الخريطة التفاعلية'), subtitle: LanguageController.text('Public guidance and room routes', 'إرشاد عام ومسارات الغرف'), icon: Icons.map_outlined, route: '/navigation'),
    ];

List<QuickAction> get visitorActions => [
      QuickAction(title: LanguageController.text('Interactive Map', 'الخريطة التفاعلية'), subtitle: LanguageController.text('Entrances, rooms, and visitor paths', 'المداخل والغرف ومسارات الزوار'), icon: Icons.map_outlined, route: '/navigation'),
      QuickAction(title: LanguageController.text('Smart Assistant', 'المساعد الذكي'), subtitle: LanguageController.text('Ask for quick guidance', 'اطلب إرشادًا سريعًا'), icon: Icons.auto_awesome_outlined, route: '/assistant'),
      QuickAction(title: LanguageController.text('Public Events', 'الفعاليات العامة'), subtitle: LanguageController.text('Open university happenings', 'اطلع على فعاليات الجامعة المفتوحة'), icon: Icons.event_outlined, route: '/admin-event'),
      QuickAction(title: LanguageController.text('Visitor Information', 'معلومات الزائر'), subtitle: LanguageController.text('Admissions and campus services', 'القبول وخدمات الحرم'), icon: Icons.info_outline_rounded, route: '/visitor-info'),
    ];

List<ScheduleItem> get studentSchedule => [
      ScheduleItem(title: LanguageController.text('Software Engineering', 'هندسة البرمجيات'), time: '08:00 - 09:20', meta: '', place: 'القاعة 205', days: 'أحد • ثلاثاء • خميس', accent: const Color(0xFF0F5B57)),
      ScheduleItem(title: LanguageController.text('Human Computer Interaction', 'التفاعل بين الإنسان والحاسوب'), time: '11:00 - 12:20', meta: '', place: 'القاعة 119', days: 'أحد • ثلاثاء', accent: const Color(0xFF26476D)),
    ];

List<ScheduleItem> get facultySchedule => [
      ScheduleItem(title: LanguageController.text('Advanced AI Ethics', 'أخلاقيات الذكاء الاصطناعي المتقدمة'), time: '09:00 - 10:15', meta: LanguageController.text('Section 201', 'الشعبة 201'), place: LanguageController.text('Lecture Hall 4B', 'قاعة المحاضرات 4B'), accent: const Color(0xFF0F5B57)),
      ScheduleItem(title: LanguageController.text('Neural Networks', 'الشبكات العصبية'), time: '01:30 - 02:45', meta: LanguageController.text('Section 104', 'الشعبة 104'), place: LanguageController.text('Computing Lab 12', 'معمل الحاسب 12'), accent: const Color(0xFF26476D)),
      ScheduleItem(title: LanguageController.text('Office Hours', 'الساعات المكتبية'), time: '03:00 - 04:00', meta: LanguageController.text('Student Support', 'دعم الطلاب'), place: LanguageController.text('Faculty Wing 2', 'جناح أعضاء هيئة التدريس 2'), accent: const Color(0xFFB38A3D)),
    ];

List<AlertItem> get alerts => [
      AlertItem(title: LanguageController.text('Registration Window Reminder', 'تذكير بفترة التسجيل'), body: LanguageController.text('Course adjustment closes tomorrow at 2:00 PM for undergraduate students.', 'إضافة وحذف المقررات يغلق غدًا الساعة 2:00 ظهرًا لطلاب البكالوريوس.'), time: LanguageController.text('8 min ago', 'منذ 8 دقائق'), icon: Icons.school_outlined, tone: const Color(0xFF0F5B57)),
      AlertItem(title: LanguageController.text('Main Campus Access', 'الوصول إلى الحرم الرئيسي'), body: LanguageController.text('Gate 3 is operating on a temporary detour due to maintenance activity.', 'تعمل البوابة 3 بمسار مؤقت بسبب أعمال الصيانة.'), time: LanguageController.text('42 min ago', 'منذ 42 دقيقة'), icon: Icons.directions_walk_rounded, tone: const Color(0xFFB76E12)),
      AlertItem(title: LanguageController.text('College of Computing Event', 'فعالية كلية الحاسب'), body: LanguageController.text('Innovation Forum opens tonight with guest talks and project showcases.', 'يفتتح منتدى الابتكار الليلة بجلسات ضيوف وعروض للمشاريع.'), time: LanguageController.text('Today', 'اليوم'), icon: Icons.event_outlined, tone: const Color(0xFF26476D)),
    ];
