import 'package:flutter/material.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/notifications_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  String _targetType = 'Group';
  String _audience = 'All Users';
  String _priority = 'Normal';
  final TextEditingController _titleController = TextEditingController(text: 'Registration Window Reminder');
  final TextEditingController _bodyController = TextEditingController(text: 'Course adjustment closes tomorrow at 2:00 PM. Please review your schedule before the deadline.');
  bool _publishing = false;

  List<String> get _audiences {
    if (_targetType == 'Individual') {
      return const ['s1234567@uqu.edu.sa', 'faculty@uqu.edu.sa', 'admin@uqu.edu.sa'];
    }
    return const ['All Users', 'Student', 'Faculty', 'Visitors'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = currentUserRole(context, fallback: UserRole.admin);
    return AppScaffold(
      bottomNavigationBar: const RoleBottomNav(currentIndex: 1, items: NavItems.admin, role: UserRole.admin),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          BrandHeader(
            subtitle: LanguageController.text('Announcement publishing', 'نشر الإعلانات'),
            trailing: IconButton(onPressed: () => smartBack(context, role), icon: const Icon(Icons.arrow_back_rounded)),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            gradient: const LinearGradient(colors: [Color(0xFF3F2B16), Color(0xFF7B5A23), Color(0xFFB38A3D)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AccentPill(label: LanguageController.text('ADMIN BROADCAST', 'بث الإدارة'), icon: Icons.campaign_outlined, filled: true),
              const SizedBox(height: 16),
              Text(LanguageController.text('Create a campus announcement.', 'أنشئ إعلانًا للحرم الجامعي.'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              Text(LanguageController.text('Published announcements are stored and shown to the selected audience.', 'تُحفظ الإعلانات المنشورة وتظهر للفئة المستهدفة.'), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(.82))),
            ]),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(controller: _titleController, decoration: InputDecoration(labelText: LanguageController.text('Announcement title', 'عنوان الإعلان'), prefixIcon: const Icon(Icons.title_rounded))),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _targetType,
                decoration: InputDecoration(labelText: LanguageController.text('Target type', 'نوع الاستهداف')),
                items: const ['Group', 'Individual'].map((item) => DropdownMenuItem(value: item, child: Text(LanguageController.translateRaw(item)))).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _targetType = value;
                    _audience = _audiences.first;
                  });
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _audiences.contains(_audience) ? _audience : _audiences.first,
                isExpanded: true,
                decoration: InputDecoration(labelText: _targetType == 'Group' ? LanguageController.text('Audience group', 'الفئة المستهدفة') : LanguageController.text('Recipient', 'المستلم')),
                items: _audiences.map((item) => DropdownMenuItem(value: item, child: Text(LanguageController.translateRaw(item), overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (value) => setState(() => _audience = value ?? _audiences.first),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: InputDecoration(labelText: LanguageController.text('Priority', 'الأولوية')),
                items: const ['Normal', 'Important', 'Urgent'].map((item) => DropdownMenuItem(value: item, child: Text(LanguageController.translateRaw(item)))).toList(),
                onChanged: (value) => setState(() => _priority = value ?? 'Normal'),
              ),
              const SizedBox(height: 14),
              SizedBox(height: 170, child: TextField(controller: _bodyController, maxLines: null, expands: true, decoration: InputDecoration(labelText: LanguageController.text('Announcement body', 'محتوى الإعلان'), alignLabelWithHint: true))),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: GradientButton(label: _publishing ? LanguageController.text('Publishing...', 'جاري النشر...') : LanguageController.text('Publish', 'نشر'), icon: Icons.campaign_outlined, onPressed: _publishing ? null : _publishAnnouncement),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            child: Row(children: [
              Container(width: 54, height: 54, decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(LanguageController.text('Delivery preview', 'معاينة الإرسال'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${LanguageController.translateRaw(_priority)} → ${LanguageController.translateRaw(_audience)}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.ink)),
              ])),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _publishAnnouncement() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      _showMessage(LanguageController.text('Announcement title and body are required.', 'عنوان الإعلان ومحتواه مطلوبان.'));
      return;
    }
    setState(() => _publishing = true);
    try {
      await NotificationsService.instance.sendNotification(
        senderRole: UserRole.admin,
        targetType: _targetType,
        targetValue: _audience,
        title: title,
        body: body,
        category: _priority,
        isAdminMessage: true,
      );
      if (!mounted) return;
      setState(() => _publishing = false);
      _showMessage(LanguageController.text('Announcement published for $_audience', 'تم نشر الإعلان لـ $_audience'));
    } catch (_) {
      if (!mounted) return;
      setState(() => _publishing = false);
      _showMessage(LanguageController.text('Unable to publish announcement now.', 'تعذر نشر الإعلان الآن.'));
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
