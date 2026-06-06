import 'package:flutter/material.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = currentUserRole(context);
    final profile = profileForRole(role);
    final session = activeSessionProfile;

    return AppScaffold(
      bottomNavigationBar: RoleBottomNav(currentIndex: 3, items: NavItems.forRole(role), role: role),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          BrandHeader(subtitle: LanguageController.text('Profile and settings', 'الملف الشخصي والإعدادات')),
          const SizedBox(height: 24),
          SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(22)), child: Icon(profile.icon, color: AppColors.primary, size: 34)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(profile.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ])),
              ]),
              const SizedBox(height: 20),
              _ProfileDetail(label: LanguageController.text('Role', 'الدور'), value: role.label, icon: iconForRole(role)),
              const SizedBox(height: 10),
              _ProfileDetail(label: LanguageController.text('Email', 'البريد الإلكتروني'), value: session?.email ?? profile.subtitle.split('•').last.trim(), icon: Icons.mail_outline_rounded),
              const SizedBox(height: 10),
              _ProfileDetail(label: LanguageController.text('University ID', 'الرقم الجامعي'), value: session?.universityId.isNotEmpty == true ? session!.universityId : LanguageController.text('Not provided', 'غير متوفر'), icon: Icons.badge_outlined),
              const SizedBox(height: 20),
              InfoTile(
                icon: Icons.language_rounded,
                title: LanguageController.text('Language', 'اللغة'),
                subtitle: LanguageController.isArabic.value ? 'العربية مفعلة' : 'English is active',
                onTap: () => _showLanguageSheet(context),
              ),
              const SizedBox(height: 12),
              InfoTile(
                icon: Icons.notifications_none_rounded,
                title: LanguageController.text('Notification Preferences', 'تفضيلات الإشعارات'),
                subtitle: LanguageController.text('Academic, events, and university updates', 'الأكاديمي والفعاليات وتحديثات الجامعة'),
                onTap: () => _showNotificationSheet(context),
              ),
              const SizedBox(height: 12),
              InfoTile(
                icon: Icons.privacy_tip_outlined,
                title: LanguageController.text('Privacy & Access', 'الخصوصية والوصول'),
                subtitle: LanguageController.text('Session status and account access', 'حالة الجلسة والوصول إلى الحساب'),
                onTap: () => _showAccessSheet(context, role),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () async {
                  await AuthService.instance.signOut();
                  clearActiveSessionProfile();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(LanguageController.text('Log Out', 'تسجيل الخروج')),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(LanguageController.text('Language', 'اللغة'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _SheetAction(
            icon: Icons.translate_rounded,
            title: 'English',
            subtitle: LanguageController.text('Use the current English interface', 'استخدم الواجهة الإنجليزية الحالية'),
            selected: !LanguageController.isArabic.value,
            onTap: () async {
              await LanguageController.setArabic(false);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          _SheetAction(
            icon: Icons.language_rounded,
            title: 'العربية',
            subtitle: 'تفعيل الواجهة العربية واتجاه RTL',
            selected: LanguageController.isArabic.value,
            onTap: () async {
              await LanguageController.setArabic(true);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(LanguageController.text('Notification Preferences', 'تفضيلات الإشعارات'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _PreferenceSwitch(title: LanguageController.text('Academic notifications', 'الإشعارات الأكاديمية'), subtitle: LanguageController.text('Schedules, faculty messages, and course updates', 'الجداول ورسائل أعضاء هيئة التدريس وتحديثات المقررات'), value: true),
          const SizedBox(height: 10),
          _PreferenceSwitch(title: LanguageController.text('University announcements', 'إعلانات الجامعة'), subtitle: LanguageController.text('Admin broadcasts and campus updates', 'رسائل الإدارة وتحديثات الحرم الجامعي'), value: true),
          const SizedBox(height: 10),
          _PreferenceSwitch(title: LanguageController.text('Events', 'الفعاليات'), subtitle: LanguageController.text('Workshops, forums, and public activities', 'ورش العمل والملتقيات والأنشطة العامة'), value: false),
        ]),
      ),
    );
  }

  void _showAccessSheet(BuildContext context, UserRole role) {
    final session = activeSessionProfile;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(LanguageController.text('Privacy & Access', 'الخصوصية والوصول'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _AccessLine(label: LanguageController.text('Signed in as', 'مسجل الدخول باسم'), value: session?.email ?? LanguageController.text('Current user', 'المستخدم الحالي')),
          const SizedBox(height: 10),
          _AccessLine(label: LanguageController.text('Workspace', 'مساحة العمل'), value: role.label),
          const SizedBox(height: 10),
          _AccessLine(label: LanguageController.text('Session', 'الجلسة'), value: LanguageController.text('Active', 'نشطة')),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              icon: const Icon(Icons.lock_reset_rounded),
              label: Text(LanguageController.text('Change Password', 'تغيير كلمة المرور')),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ProfileDetail({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text('$label:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _SheetAction({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(.09) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.line),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? AppColors.primary : AppColors.muted),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ])),
          if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
        ]),
      ),
    );
  }
}

class _PreferenceSwitch extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool value;
  const _PreferenceSwitch({required this.title, required this.subtitle, required this.value});

  @override
  State<_PreferenceSwitch> createState() => _PreferenceSwitchState();
}

class _PreferenceSwitchState extends State<_PreferenceSwitch> {
  late bool enabled = widget.value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ])),
        Switch(value: enabled, activeColor: AppColors.primary, onChanged: (value) => setState(() => enabled = value)),
      ]),
    );
  }
}

class _AccessLine extends StatelessWidget {
  final String label;
  final String value;
  const _AccessLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 110, child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink))),
      Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
    ]);
  }
}
