import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_content.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/events_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final events = await EventsService.instance.listEvents();
      if (mounted) setState(() => _events = events.take(3).toList());
    } catch (_) {}
  }

  Future<void> _navigate(String route) async {
    await Navigator.pushNamed(context, route, arguments: UserRole.student);
    if (mounted) _loadData();
  }

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      bottomNavigationBar: const RoleBottomNav(
        currentIndex: 0,
        items: NavItems.student,
        role: UserRole.student,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          // ── Header ───────────────────────────────────────────────
          BrandHeader(
            subtitle: currentUserRole(context).workspaceLabel,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              NotifBell(route: '/notifications', arguments: UserRole.student),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/profile', arguments: UserRole.student),
                icon: const Icon(Icons.person_outline_rounded),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Welcome ──────────────────────────────────────────────
          Text(
            LanguageController.text(
              'Good morning, ${firstNameForRole(UserRole.student)}.',
              'صباح الخير، ${firstNameForRole(UserRole.student)}.',
            ),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // ── Services ─────────────────────────────────────────────
          SectionTitle(title: LanguageController.text('Services', 'الخدمات')),
          const SizedBox(height: 12),

          // Smart Assistant — full-width
          InkWell(
            onTap: () => _navigate('/assistant'),
            borderRadius: BorderRadius.circular(22),
            child: SurfaceCard(
              gradient: const LinearGradient(colors: [Color(0xFF152B44), Color(0xFF26476D)]),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    LanguageController.text('Smart Assistant', 'المساعد الذكي'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    LanguageController.text('Ask me anything about the university', 'اسألني أي شيء عن الجامعة'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
                  ),
                ])),
                const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // 3-column service grid
          GridView.builder(
            itemCount: studentActions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final item = studentActions[index];
              return InkWell(
                onTap: () => _navigate(item.route),
                borderRadius: BorderRadius.circular(20),
                child: SurfaceCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.mist,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── University portals ────────────────────────────────────
          SectionTitle(title: LanguageController.text('University Portals', 'البوابات الجامعية')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _PortalButton(
              label: LanguageController.text('UQU Website', 'موقع أم القرى'),
              subtitle: LanguageController.text('Official website', 'الموقع الرسمي'),
              icon: Icons.school_outlined,
              url: 'https://www.uqu.edu.sa',
              color: AppColors.primary,
            )),
            const SizedBox(width: 12),
            Expanded(child: _PortalButton(
              label: LanguageController.text('Blackboard', 'البلاك بورد'),
              subtitle: LanguageController.text('Learning management', 'إدارة التعلم'),
              icon: Icons.laptop_outlined,
              url: 'https://uqu.blackboard.com',
              color: AppColors.secondary,
            )),
          ]),

          // ── Events ───────────────────────────────────────────────
          if (_events.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: SectionTitle(title: LanguageController.text('Upcoming Events', 'الفعاليات القادمة'))),
              TextButton(
                onPressed: () => _navigate('/admin-event'),
                child: Text(LanguageController.text('View all', 'عرض الكل')),
              ),
            ]),
            const SizedBox(height: 8),
            ..._events.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _navigate('/admin-event'),
                borderRadius: BorderRadius.circular(22),
                child: _EventCard(event: e),
              ),
            )),
          ],
        ],
      ),
    );
  }
}

// ── Portal button ─────────────────────────────────────────────────────────────
class _PortalButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final String url;
  final Color color;
  const _PortalButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          try {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(LanguageController.text('Could not open link', 'تعذّر فتح الرابط'))),
              );
            }
          }
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: SurfaceCard(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.open_in_new_rounded, size: 14),
              label: Text(LanguageController.text('Open', 'فتح')),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: color,
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Inline event card ─────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.event_outlined, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            event['title']?.toString() ?? '',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.muted),
            const SizedBox(width: 4),
            Text(
              event['event_date']?.toString() ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 12),
            const Icon(Icons.place_outlined, size: 13, color: AppColors.muted),
            const SizedBox(width: 4),
            Expanded(child: Text(
              event['location']?.toString() ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            )),
          ]),
        ])),
      ]),
    );
  }
}
