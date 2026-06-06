import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_content.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class FacultyHomeScreen extends StatelessWidget {
  const FacultyHomeScreen({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pushNamed(context, route, arguments: UserRole.faculty);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: const RoleBottomNav(
        currentIndex: 0,
        items: NavItems.faculty,
        role: UserRole.faculty,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          // ── Header ───────────────────────────────────────────────
          BrandHeader(
            subtitle: currentUserRole(context).workspaceLabel,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              NotifBell(route: '/notifications'),
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
              'Good morning, ${firstNameForRole(UserRole.faculty)}.',
              'صباح الخير، ${firstNameForRole(UserRole.faculty)}.',
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
            itemCount: facultyActions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final item = facultyActions[index];
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

          // ── Teaching Schedule ─────────────────────────────────────
          SectionTitle(
            title: LanguageController.text('Teaching Schedule', 'جدول التدريس'),
            action: LanguageController.text('Open schedule', 'فتح الجدول'),
            onAction: () => _navigate(context, '/schedule'),
          ),
          const SizedBox(height: 12),
          _FacultyScheduleCard(item: ScheduleItem(
            title: LanguageController.text('Software Engineering', 'هندسة البرمجيات'),
            time: '08:00 - 09:20',
            meta: LanguageController.text('Section 201', 'الشعبة 201'),
            place: LanguageController.text('Hall 205', 'القاعة 205'),
            days: LanguageController.text('Sun • Tue • Thu', 'أحد • ثلاثاء • خميس'),
            accent: const Color(0xFF0F5B57),
          )),
          const SizedBox(height: 12),
          _FacultyScheduleCard(item: ScheduleItem(
            title: LanguageController.text('Human Computer Interaction', 'التفاعل بين الإنسان والحاسوب'),
            time: '11:00 - 12:20',
            meta: LanguageController.text('Section 104', 'الشعبة 104'),
            place: LanguageController.text('Hall 119', 'القاعة 119'),
            days: LanguageController.text('Sun • Tue', 'أحد • ثلاثاء'),
            accent: const Color(0xFF26476D),
          )),
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

// ── Faculty schedule card ─────────────────────────────────────────────────────
class _FacultyScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  const _FacultyScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 12,
            height: 60,
            decoration: BoxDecoration(color: item.accent, borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(item.meta, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(item.time, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
          ])),
        ]),
        const SizedBox(height: 12),
        Material(
          color: item.accent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pushNamed(context, '/navigation', arguments: item.place),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(item.place, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
