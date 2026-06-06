import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_content.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  final _scrollController = ScrollController();
  final _infoKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigate(String route) {
    if (route == '/visitor-info') {
      final ctx = _infoKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
      return;
    }
    Navigator.pushNamed(context, route, arguments: UserRole.visitor);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: const RoleBottomNav(
        currentIndex: 0,
        items: NavItems.visitor,
        role: UserRole.visitor,
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          // ── Header ───────────────────────────────────────────────
          BrandHeader(
            subtitle: currentUserRole(context, fallback: UserRole.visitor).workspaceLabel,
            trailing: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              child: Text(LanguageController.text('Login', 'تسجيل الدخول')),
            ),
          ),
          const SizedBox(height: 24),

          // ── Welcome ──────────────────────────────────────────────
          Text(
            LanguageController.text('Welcome to UQU.', 'مرحبًا بك في أم القرى.'),
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
              gradient: const LinearGradient(colors: [Color(0xFF123836), Color(0xFF0F5B57)]),
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
            itemCount: visitorActions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final item = visitorActions[index];
              return InkWell(
                onTap: () => _navigate(item.route),
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

          // ── University portals ────────────────────────────────────
          SectionTitle(title: LanguageController.text('University Portals', 'البوابات الجامعية')),
          const SizedBox(height: 12),
          _PortalButton(
            label: LanguageController.text('UQU Website', 'موقع أم القرى'),
            subtitle: LanguageController.text('Official website', 'الموقع الرسمي'),
            icon: Icons.school_outlined,
            url: 'https://www.uqu.edu.sa',
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),

          // ── Visitor Information ───────────────────────────────────
          SectionTitle(key: _infoKey, title: LanguageController.text('Visitor Information', 'معلومات الزائر')),
          const SizedBox(height: 12),
          SurfaceCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D3330), Color(0xFF0F5B57)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    LanguageController.text('Umm Al-Qura University', 'جامعة أم القرى'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    LanguageController.text('Makkah Al-Mukarramah, Saudi Arabia', 'مكة المكرمة، المملكة العربية السعودية'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
                  ),
                ])),
              ]),
              const SizedBox(height: 20),

              // Stats row
              Row(children: [
                _StatChip(value: '1949', label: LanguageController.text('Founded', 'تأسست')),
                const SizedBox(width: 10),
                _StatChip(value: '100K+', label: LanguageController.text('Students', 'طالب')),
                const SizedBox(width: 10),
                _StatChip(value: '20+', label: LanguageController.text('Colleges', 'كلية')),
              ]),
              const SizedBox(height: 20),

              Text(
                LanguageController.text(
                  'Welcome to Umm Al-Qura University — one of Saudi Arabia\'s most distinguished academic institutions, located in the heart of Makkah Al-Mukarramah.',
                  'مرحبًا بكم في جامعة أم القرى — إحدى أبرز المؤسسات الأكاديمية في المملكة العربية السعودية، الواقعة في قلب مكة المكرمة.',
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: .9), height: 1.6),
              ),
              const SizedBox(height: 14),

              Text(
                LanguageController.text(
                  'UQU has grown into a comprehensive university serving over 100,000 students across a wide range of colleges — including Engineering, Computing, Medicine, Islamic Studies, and more.',
                  'نمت الجامعة لتصبح مؤسسة جامعية شاملة تخدم أكثر من 100,000 طالب في مجموعة واسعة من الكليات، منها الهندسة والحاسب والطب والدراسات الإسلامية وغيرها.',
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: .82), height: 1.6),
              ),
              const SizedBox(height: 14),

              Text(
                LanguageController.text(
                  'The university spans a modern campus featuring state-of-the-art lecture halls, research laboratories, libraries, and administrative centers — all designed to support an exceptional academic environment.',
                  'يمتد الحرم الجامعي ليشمل قاعات محاضرات ومختبرات بحثية ومكتبات ومراكز إدارية متطورة، جميعها مصممة لدعم بيئة أكاديمية متميزة.',
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: .82), height: 1.6),
              ),
              const SizedBox(height: 14),

              Text(
                LanguageController.text(
                  'UQU is committed to academic excellence, scientific research, and community service — aligned with Saudi Vision 2030 and the Kingdom\'s goals for knowledge and innovation.',
                  'تلتزم الجامعة بالتميز الأكاديمي والبحث العلمي وخدمة المجتمع، بما يتوافق مع رؤية المملكة 2030 وأهدافها في المعرفة والابتكار.',
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: .82), height: 1.6),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('https://www.uqu.edu.sa');
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      await launchUrl(uri, mode: LaunchMode.inAppWebView);
                    }
                  },
                  icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 16),
                  label: Text(
                    LanguageController.text('Visit www.uqu.edu.sa', 'زيارة www.uqu.edu.sa'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ]),
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
