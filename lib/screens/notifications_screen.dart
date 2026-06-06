import 'package:flutter/material.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/notifications_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<_NotificationsBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    final role = currentUserRole(context);
    final bottomIndex = role == UserRole.visitor ? 3 : (role == UserRole.admin ? 0 : 2);

    return AppScaffold(
      bottomNavigationBar: RoleBottomNav(currentIndex: bottomIndex, items: NavItems.forRole(role), role: role),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          BrandHeader(
            subtitle: role == UserRole.visitor ? LanguageController.text('Public events and updates', 'الفعاليات العامة والتحديثات') : LanguageController.text('Announcements, alerts, and updates', 'الإعلانات والتنبيهات والتحديثات'),
            trailing: IconButton(onPressed: () => smartBack(context, currentUserRole(context)), icon: const Icon(Icons.arrow_back_rounded)),
          ),
          const SizedBox(height: 24),
          FutureBuilder<_NotificationsBundle>(
            future: _future,
            builder: (context, snapshot) {
              final bundle = snapshot.data;
              return SurfaceCard(
                child: Row(children: [
                  AccentPill(label: role == UserRole.visitor ? LanguageController.text('PUBLIC UPDATES', 'تحديثات عامة') : LanguageController.text('NOTIFICATIONS', 'الإشعارات'), icon: Icons.notifications_active_outlined),
                  const Spacer(),
                  IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
                  TextButton(onPressed: bundle == null ? null : () => _markAllRead(bundle.items), child: Text(LanguageController.text('Mark all read', 'تعيين الكل كمقروء'))),
                ]),
              );
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder<_NotificationsBundle>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SurfaceCard(child: Text(LanguageController.text('Unable to load notifications right now.', 'تعذر تحميل الإشعارات الآن.'), style: Theme.of(context).textTheme.bodyLarge));
              }
              final bundle = snapshot.data ?? const _NotificationsBundle(items: [], readIds: <String>{});
              final doctorAlerts = bundle.items.where((item) => item['is_admin_message'] != true).toList();
              final adminAlerts = bundle.items.where((item) => item['is_admin_message'] == true).toList();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (role != UserRole.visitor) ...[
                  _NotificationSection(title: LanguageController.text('From Doctors', 'من أعضاء هيئة التدريس'), items: doctorAlerts, readIds: bundle.readIds, onOpen: _openNotification),
                  const SizedBox(height: 18),
                ],
                _NotificationSection(title: role == UserRole.visitor ? LanguageController.text('Public Updates', 'تحديثات عامة') : LanguageController.text('From Admin', 'من الإدارة'), items: adminAlerts, readIds: bundle.readIds, onOpen: _openNotification),
              ]);
            },
          ),
        ],
      ),
    );
  }

  Future<_NotificationsBundle> _load() async {
    final items = await NotificationsService.instance.listNotifications();
    final readIds = await NotificationsService.instance.listReadIds();
    final unread = items.where((n) {
      final id = n['id']?.toString() ?? '';
      return id.isNotEmpty && !readIds.contains(id);
    }).length;
    NotificationsService.unreadCount.value = unread;
    return _NotificationsBundle(items: items, readIds: readIds);
  }

  void _reload() => setState(() { _future = _load(); });

  Future<void> _markAllRead(List<Map<String, dynamic>> items) async {
    await NotificationsService.instance.markAllRead(items.map((item) => item['id']?.toString() ?? ''));
    NotificationsService.unreadCount.value = 0;
    _reload();
    _showMessage(LanguageController.text('All notifications marked as read', 'تم تعيين جميع الإشعارات كمقروءة'));
  }

  Future<void> _openNotification(Map<String, dynamic> item) async {
    final id = item['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      await NotificationsService.instance.markRead(id);
      _reload();
    }
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['title']?.toString() ?? '', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(item['body']?.toString() ?? '', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 14),
          _NotifMeta(item: item, large: true),
        ]),
      ),
    );
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _NotificationsBundle {
  final List<Map<String, dynamic>> items;
  final Set<String> readIds;
  const _NotificationsBundle({required this.items, required this.readIds});
}

class _NotificationSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Set<String> readIds;
  final ValueChanged<Map<String, dynamic>> onOpen;
  const _NotificationSection({required this.title, required this.items, required this.readIds, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle(title: title),
      const SizedBox(height: 12),
      if (items.isEmpty)
        SurfaceCard(child: Text(LanguageController.text('No notifications available.', 'لا توجد إشعارات متاحة.'), style: Theme.of(context).textTheme.bodyLarge))
      else
        ...items.map((item) {
          final id = item['id']?.toString() ?? '';
          final isRead = readIds.contains(id);
          final isAdmin = item['is_admin_message'] == true;
          final tone = isAdmin ? AppColors.secondary : AppColors.primary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onOpen(item),
              borderRadius: BorderRadius.circular(30),
              child: SurfaceCard(
                borderColor: isRead ? AppColors.line.withOpacity(.6) : tone.withOpacity(.35),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: tone.withOpacity(isRead ? .08 : .12), borderRadius: BorderRadius.circular(16)), child: Icon(isAdmin ? Icons.campaign_outlined : Icons.school_outlined, color: tone)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(item['title']?.toString() ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16))),
                      if (!isRead) ...[
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: tone, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                      ],
                      Text(_formatTime(item['created_at']?.toString()), style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                    const SizedBox(height: 4),
                    Text(item['body']?.toString() ?? '', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 6),
                    _NotifMeta(item: item),
                  ])),
                ]),
              ),
            ),
          );
        }),
    ]);
  }
}

class _NotifMeta extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool large;
  const _NotifMeta({required this.item, this.large = false});

  @override
  Widget build(BuildContext context) {
    final senderName = item['sender_name']?.toString() ?? '';
    final course = item['target_value']?.toString() ?? '';
    final role = item['sender_role']?.toString() ?? '';
    final date = _formatTime(item['created_at']?.toString());

    final sender = senderName.isNotEmpty ? senderName : role;
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: large ? 13 : 11,
      color: const Color(0xFF7B8794),
    );

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (sender.isNotEmpty) _chip(Icons.person_outline, sender, style),
        if (course.isNotEmpty && course != 'All Users') _chip(Icons.menu_book_outlined, course, style),
        _chip(Icons.access_time_outlined, date, style),
      ],
    );
  }

  Widget _chip(IconData icon, String label, TextStyle? style) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: const Color(0xFF9AA6B2)),
      const SizedBox(width: 3),
      Text(label, style: style),
    ]);
  }
}

String _formatTime(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;
  final local = date.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
