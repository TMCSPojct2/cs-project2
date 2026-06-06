import 'package:flutter/material.dart';
import 'role_context.dart';
import 'language_controller.dart';

class AssistantReply {
  final String text;
  final List<AssistantAction> actions;
  const AssistantReply({required this.text, this.actions = const []});
}

class AssistantAction {
  final String label;
  final IconData icon;
  final String route;
  const AssistantAction({required this.label, required this.icon, required this.route});
}

List<String> assistantSuggestionsForRole(UserRole role) {
  if (LanguageController.isArabic.value) {
    return const [
      'ما هي جامعة أم القرى؟',
      'متى تبدأ الاختبارات النهائية؟',
      'كم عدد ساعات مادة هندسة البرمجيات؟',
      'ما شروط الاعتذار عن مقرر؟',
      'كيف أحسب المعدل الفصلي؟',
      'ما الخدمات المتاحة للطلاب؟',
    ];
  }
  return const [
    'What is Umm Al-Qura University?',
    'When do final exams start?',
    'How many credit hours is Software Engineering?',
    'What are the course withdrawal rules?',
    'How do I calculate semester GPA?',
    'What student services are available?',
  ];
}


String assistantWelcomeForRole(UserRole role) {
  return LanguageController.text(
    'Ask about Umm Al-Qura University, courses, credit hours, exams, academic rules, and student services.',
    'اسأل عن جامعة أم القرى، المقررات، الساعات، الاختبارات، الأنظمة الأكاديمية، وخدمات الطلاب.',
  );
}


AssistantReply assistantReplyForPrompt(String prompt, UserRole role) {
  final text = prompt.toLowerCase();

  if (_matches(text, const ['where', 'route', 'navigate', 'navigation', 'location', 'room', 'hall', 'gate', 'building', 'services'])) {
    return _navigationReply(role);
  }
  if (_matches(text, const ['event', 'activity', 'forum', 'open'])) {
    return _eventReply(role);
  }
  if (_matches(text, const ['announcement', 'announcements', 'alert', 'alerts', 'update', 'updates', 'notice', 'priority'])) {
    return _announcementReply(role);
  }
  if (_matches(text, const ['draft', 'message', 'reminder', 'notify', 'notification', 'section'])) {
    return _communicationReply(role);
  }
  if (_matches(text, const ['gpa', 'grade', 'grades', 'semester', 'performance'])) {
    return _gpaReply(role);
  }
  if (_matches(text, const ['schedule', 'class', 'lecture', 'teaching', 'today', 'prepare'])) {
    return _scheduleReply(role);
  }

  return _fallbackReply(role);
}

bool _matches(String text, List<String> words) {
  return words.any(text.contains);
}

AssistantReply _scheduleReply(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return const AssistantReply(
        text: 'Your teaching day is focused: Advanced AI Ethics is first, Neural Networks follows after midday, and office hours close the afternoon. I would review Section 201 notes first, then prepare one concise reminder for the later lab group.',
        actions: [AssistantAction(label: 'Open Schedule', icon: Icons.calendar_month_rounded, route: '/schedule')],
      );
    case UserRole.admin:
      return const AssistantReply(
        text: 'There is no personal class schedule attached to the admin workspace. For today, the useful view is operational: announcement reach, public event readiness, and active campus access notices.',
        actions: [AssistantAction(label: 'Open Updates', icon: Icons.notifications_none_rounded, route: '/notifications')],
      );
    case UserRole.visitor:
      return const AssistantReply(
        text: 'Visitor mode does not include academic schedules. I can help with public events, campus services, and the best entry point for your visit.',
        actions: [AssistantAction(label: 'Interactive Map', icon: Icons.map_outlined, route: '/navigation')],
      );
    case UserRole.student:
      return const AssistantReply(
        text: 'Your day starts with Software Engineering, then Data Communication Lab at 10:00 AM, followed by HCI after midday. The next best step is to prepare lab material and confirm the room before leaving.',
        actions: [AssistantAction(label: 'Open Schedule', icon: Icons.calendar_month_rounded, route: '/schedule')],
      );
  }
}

AssistantReply _navigationReply(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return const AssistantReply(
        text: 'For faculty routes, start from your current building, then confirm the lecture hall or lab name. Lecture Hall 4B and Computing Lab 12 are the most relevant teaching destinations in the campus map.',
        actions: [AssistantAction(label: 'Open Navigation', icon: Icons.map_outlined, route: '/navigation')],
      );
    case UserRole.admin:
      return const AssistantReply(
        text: 'For administrative wayfinding, the current map highlights public touchpoints: Main Gate 3, Student Services, the Library, and the College of Computing. These are suitable for directing visitors or campus-wide notices.',
        actions: [AssistantAction(label: 'Open Navigation', icon: Icons.map_outlined, route: '/navigation')],
      );
    case UserRole.visitor:
      return const AssistantReply(
        text: 'Visitors should start at Main Gate 3 for parking and reception access. From there, Student Services is the clearest support destination, and public events are usually easiest to confirm from the updates screen.',
        actions: [AssistantAction(label: 'Open Navigation', icon: Icons.map_outlined, route: '/navigation')],
      );
    case UserRole.student:
      return const AssistantReply(
        text: 'For class movement, check the building and room before you leave. Your schedule includes Building C Room 204 and Building A Room 118, while the lab is listed as Innovation Lab 2.',
        actions: [AssistantAction(label: 'Open Navigation', icon: Icons.map_outlined, route: '/navigation')],
      );
  }
}

AssistantReply _eventReply(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return const AssistantReply(
        text: 'The College of Computing Innovation Forum is the main highlighted event. If your section is involved, send a short reminder with time, location, and expected preparation.',
        actions: [AssistantAction(label: 'Notify Section', icon: Icons.send_outlined, route: '/faculty-notify')],
      );
    case UserRole.admin:
      return const AssistantReply(
        text: 'The current event priority is the Innovation Forum. A useful admin update should include audience, location, start time, access notes, and whether visitor attendance is open.',
        actions: [AssistantAction(label: 'Create Event', icon: Icons.event_available_rounded, route: '/admin-event')],
      );
    case UserRole.visitor:
      return const AssistantReply(
        text: 'The public highlight is the Innovation Forum. Visitor access appears open through the main auditorium, with Gate 3 recommended for arrival and parking.',
        actions: [AssistantAction(label: 'Open Updates', icon: Icons.notifications_none_rounded, route: '/notifications')],
      );
    case UserRole.student:
      return const AssistantReply(
        text: 'The College of Computing Innovation Forum is the key activity today. If your schedule allows, review the event notice after class and check whether project showcases align with your coursework.',
        actions: [AssistantAction(label: 'Open Updates', icon: Icons.notifications_none_rounded, route: '/notifications')],
      );
  }
}

AssistantReply _announcementReply(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return const AssistantReply(
        text: 'The most relevant faculty updates are section reminders, campus access changes, and university announcements that affect class timing. Review alerts before sending any section-wide note.',
        actions: [AssistantAction(label: 'Open Alerts', icon: Icons.notifications_none_rounded, route: '/notifications')],
      );
    case UserRole.admin:
      return const AssistantReply(
        text: 'The strongest announcement priority is campus access clarity, followed by event visibility. Keep the title direct, choose the right audience, and use urgent priority only for time-sensitive operational changes.',
        actions: [AssistantAction(label: 'Create Announcement', icon: Icons.campaign_outlined, route: '/announcement')],
      );
    case UserRole.visitor:
      return const AssistantReply(
        text: 'For visitors, the useful updates are entry guidance, public events, and service availability. Start with Gate 3 access and confirm whether the event you plan to attend is open to guests.',
        actions: [AssistantAction(label: 'Open Updates', icon: Icons.notifications_none_rounded, route: '/notifications')],
      );
    case UserRole.student:
      return const AssistantReply(
        text: 'Review registration timing first, then campus access notices, then college events. The registration reminder is the most time-sensitive item for a student workspace.',
        actions: [AssistantAction(label: 'Open Alerts', icon: Icons.notifications_none_rounded, route: '/notifications')],
      );
  }
}

AssistantReply _communicationReply(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return const AssistantReply(
        text: 'A strong section message should be brief: mention the section, the action needed, the deadline, and where students can ask follow-up questions. For Section 201, lead with the class topic and expected preparation.',
        actions: [AssistantAction(label: 'Send Notification', icon: Icons.send_outlined, route: '/faculty-notify')],
      );
    case UserRole.admin:
      return const AssistantReply(
        text: 'For an admin notice, keep it formal and campus-wide only when needed. Use audience targeting for students, faculty, or visitors so the update stays relevant.',
        actions: [AssistantAction(label: 'Create Announcement', icon: Icons.campaign_outlined, route: '/announcement')],
      );
    case UserRole.visitor:
      return const AssistantReply(
        text: 'Visitor mode can guide you to public information, but private messages and academic notifications require a registered university role.',
        actions: [AssistantAction(label: 'Visitor Updates', icon: Icons.notifications_none_rounded, route: '/notifications')],
      );
    case UserRole.student:
      return const AssistantReply(
        text: 'For student communication, check notifications first. If you need to contact a course team, include the course name, section, and the exact issue so the response is easier to route.',
        actions: [AssistantAction(label: 'Open Alerts', icon: Icons.notifications_none_rounded, route: '/notifications')],
      );
  }
}

AssistantReply _gpaReply(UserRole role) {
  if (role == UserRole.student) {
    return const AssistantReply(
      text: 'Your projected GPA screen is best for quick planning. Review credit hours first, then expected grade for each course, and recalculate after any grade change.',
      actions: [AssistantAction(label: 'Open GPA', icon: Icons.calculate_outlined, route: '/gpa')],
    );
  }
  return const AssistantReply(
    text: 'GPA planning is available in the student workspace. For this role, I can help more with schedules, updates, communication, and campus guidance.',
  );
}

AssistantReply _fallbackReply(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return const AssistantReply(
        text: 'I can help you review teaching schedule details, prepare a section reminder, check university alerts, or find a campus destination.',
      );
    case UserRole.admin:
      return const AssistantReply(
        text: 'I can help you shape an announcement, prepare an event update, review campus alerts, or choose the most relevant operational next step.',
      );
    case UserRole.visitor:
      return const AssistantReply(
        text: 'I can help with guest entry, public events, campus service locations, and visitor-facing updates.',
      );
    case UserRole.student:
      return const AssistantReply(
        text: 'I can help with your class schedule, GPA planning, campus navigation, student services, or the latest university alerts.',
      );
  }
}
