import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_content.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/dashboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pushNamed(context, route, arguments: UserRole.admin);
  }

  @override
  Widget build(BuildContext context) {
    final statLabels = [
      (LanguageController.text('Active users', 'المستخدمون النشطون'), Icons.groups_outlined, 'users'),
      (LanguageController.text('Announcements', 'الإعلانات'), Icons.campaign_outlined, 'announcements'),
      (LanguageController.text('Published events', 'الفعاليات المنشورة'), Icons.event_note_outlined, 'events'),
    ];

    return AppScaffold(
      bottomNavigationBar: const RoleBottomNav(currentIndex: 0, items: NavItems.admin, role: UserRole.admin),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          // ── Header ───────────────────────────────────────────────
          BrandHeader(
            subtitle: currentUserRole(context).workspaceLabel,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              NotifBell(route: '/notifications', arguments: UserRole.admin),
              IconButton(
                onPressed: () => _navigate(context, '/profile'),
                icon: const Icon(Icons.person_outline_rounded),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Welcome ──────────────────────────────────────────────
          Text(
            LanguageController.text(
              'Good morning, ${firstNameForRole(UserRole.admin)}.',
              'صباح الخير، ${firstNameForRole(UserRole.admin)}.',
            ),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // ── Services ─────────────────────────────────────────────
          SectionTitle(title: LanguageController.text('Services', 'الخدمات')),
          const SizedBox(height: 12),

          // Smart Assistant — full-width
          InkWell(
            onTap: () => _navigate(context, '/assistant'),
            borderRadius: BorderRadius.circular(22),
            child: SurfaceCard(
              gradient: const LinearGradient(colors: [Color(0xFF152B44), Color(0xFF26476D)]),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      LanguageController.text('Smart Assistant', 'المساعد الذكي'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    Text(
                      LanguageController.text('Ask me anything about the university', 'اسألني أي شيء عن الجامعة'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
                    ),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // 2-column service grid
          GridView.builder(
            itemCount: adminActions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final item = adminActions[index];
              return InkWell(
                onTap: () => _navigate(context, item.route),
                borderRadius: BorderRadius.circular(20),
                child: SurfaceCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 36,
                      height: 36,
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

          // ── Overview stats ────────────────────────────────────────
          SectionTitle(title: LanguageController.text('Overview', 'نظرة عامة')),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, int>>(
            future: DashboardService.instance.adminCounts(),
            builder: (context, snapshot) {
              final counts = snapshot.data ?? const <String, int>{};
              return GridView.builder(
                itemCount: statLabels.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final item = statLabels[index];
                  final value = snapshot.connectionState == ConnectionState.waiting
                      ? '—'
                      : (counts[item.$3] ?? 0).toString();
                  return SurfaceCard(
                    gradient: const LinearGradient(colors: [Color(0xFFFFFCF6), Colors.white]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(16)),
                        child: Icon(item.$2, color: AppColors.secondary),
                      ),
                      const Spacer(),
                      Text(item.$1, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.ink)),
                      const SizedBox(height: 6),
                      Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26)),
                    ]),
                  );
                },
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
            width: 46,
            height: 46,
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
