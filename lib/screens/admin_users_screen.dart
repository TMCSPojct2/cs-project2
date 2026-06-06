import 'package:flutter/material.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/admin_data_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _profilesFuture;
  late Future<List<Map<String, dynamic>>> _invitesFuture;
  UserRole _role = UserRole.faculty;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: const RoleBottomNav(currentIndex: 0, items: NavItems.admin, role: UserRole.admin),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          BrandHeader(
            subtitle: LanguageController.text('User access management', 'إدارة وصول المستخدمين'),
            trailing: IconButton(onPressed: () => smartBack(context, currentUserRole(context)), icon: const Icon(Icons.arrow_back_rounded)),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AccentPill(label: LanguageController.text('ACCOUNT ACCESS', 'وصول الحسابات'), icon: Icons.manage_accounts_outlined),
              const SizedBox(height: 16),
              Text(LanguageController.text('Prepare a university user invitation.', 'جهّز دعوة مستخدم جامعي.'), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(LanguageController.text('The invitation is stored for admin tracking. The user completes account verification from their email.', 'تُحفظ الدعوة لمتابعة الإدارة، ويكمل المستخدم التحقق من بريده.'), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 18),
              TextField(controller: _nameController, decoration: InputDecoration(labelText: LanguageController.text('Full Name', 'الاسم الكامل'), prefixIcon: const Icon(Icons.person_outline_rounded))),
              const SizedBox(height: 14),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: LanguageController.text('University Email', 'البريد الجامعي'), hintText: 'name@uqu.edu.sa', prefixIcon: const Icon(Icons.mail_outline_rounded))),
              const SizedBox(height: 14),
              TextField(controller: _idController, decoration: InputDecoration(labelText: LanguageController.text('University ID / Employee ID', 'الرقم الجامعي / الوظيفي'), prefixIcon: const Icon(Icons.badge_outlined))),
              const SizedBox(height: 14),
              DropdownButtonFormField<UserRole>(
                value: _role,
                decoration: InputDecoration(labelText: LanguageController.text('Role', 'الدور')),
                items: const [UserRole.student, UserRole.faculty, UserRole.admin].map((role) => DropdownMenuItem(value: role, child: Text(role.label))).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _role = value);
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: GradientButton(label: _saving ? LanguageController.text('Saving...', 'جاري الحفظ...') : LanguageController.text('Prepare Invitation', 'تجهيز الدعوة'), icon: Icons.mark_email_read_outlined, onPressed: _saving ? null : _prepareInvite),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _InvitationsPanel(future: _invitesFuture, onRefresh: _reloadData),
          const SizedBox(height: 16),
          SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(LanguageController.text('Current Users', 'المستخدمون الحاليون'), style: Theme.of(context).textTheme.titleLarge)),
                IconButton(onPressed: _reloadData, icon: const Icon(Icons.refresh_rounded)),
              ]),
              const SizedBox(height: 6),
              Text(LanguageController.text('Users shown here are loaded from the profiles table.', 'يتم تحميل المستخدمين المعروضين هنا من جدول profiles.'), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _profilesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 28), child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return _StateMessage(icon: Icons.lock_outline_rounded, title: LanguageController.text('Unable to load users', 'تعذر تحميل المستخدمين'), body: LanguageController.text('Check the admin profile policy and try again.', 'تحقق من سياسة ملف الأدمن ثم أعد المحاولة.'), tone: AppColors.secondary);
                  }
                  final users = snapshot.data ?? const [];
                  if (users.isEmpty) {
                    return _StateMessage(icon: Icons.group_off_outlined, title: LanguageController.text('No users found', 'لا يوجد مستخدمون'), body: LanguageController.text('The profiles table is empty.', 'جدول profiles فارغ.'));
                  }
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(LanguageController.text('${users.length} users loaded', 'تم تحميل ${users.length} مستخدم'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    ...users.map((user) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _UserTile(user: user))),
                  ]);
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _reloadData() {
    setState(() {
      _profilesFuture = ProfileService.instance.listProfilesForAdmin();
      _invitesFuture = AdminDataService.instance.listInvitations();
    });
  }

  Future<void> _prepareInvite() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final id = _idController.text.trim();
    if (name.isEmpty || email.isEmpty || id.isEmpty) {
      _showMessage(LanguageController.text('Complete all fields before preparing access.', 'أكمل جميع الحقول قبل تجهيز الوصول.'));
      return;
    }
    if (!email.endsWith('@uqu.edu.sa')) {
      _showMessage(LanguageController.text('Use an Umm Al-Qura University email.', 'استخدم بريد جامعة أم القرى.'));
      return;
    }
    setState(() => _saving = true);
    try {
      await AdminDataService.instance.createInvitation(fullName: name, email: email, universityId: id, role: _role);
      if (!mounted) return;
      _nameController.clear();
      _emailController.clear();
      _idController.clear();
      setState(() {
        _role = UserRole.faculty;
        _saving = false;
      });
      _reloadData();
      _showMessage(LanguageController.text('Invitation prepared for $email', 'تم تجهيز الدعوة لـ $email'));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(LanguageController.text('Unable to prepare invitation now.', 'تعذر تجهيز الدعوة الآن.'));
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _InvitationsPanel extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final VoidCallback onRefresh;
  const _InvitationsPanel({required this.future, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      gradient: const LinearGradient(colors: [Color(0xFFF8F6F1), Colors.white]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(LanguageController.text('Prepared Invitations', 'الدعوات المجهزة'), style: Theme.of(context).textTheme.titleLarge)),
          IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh_rounded)),
        ]),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final invites = snapshot.data ?? const [];
            if (invites.isEmpty) {
              return Text(LanguageController.text('No prepared invitations yet.', 'لا توجد دعوات مجهزة بعد.'), style: Theme.of(context).textTheme.bodyLarge);
            }
            return Column(children: invites.map((invite) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _InviteTile(invite: invite))).toList());
          },
        ),
      ]),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['full_name']?.toString() ?? LanguageController.text('User', 'مستخدم');
    final email = user['email']?.toString() ?? '';
    final roleRaw = user['role']?.toString() ?? 'Unknown';
    final universityId = user['university_id']?.toString() ?? '';
    final roleType = userRoleFromValue(roleRaw);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(22)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Icon(iconForRole(roleType), color: AppColors.primary)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          SelectableText(email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          SelectableText('${roleType.label} • $universityId', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
        ])),
      ]),
    );
  }
}

class _InviteTile extends StatelessWidget {
  final Map<String, dynamic> invite;
  const _InviteTile({required this.invite});

  @override
  Widget build(BuildContext context) {
    final name = invite['full_name']?.toString() ?? '';
    final email = invite['email']?.toString() ?? '';
    final role = invite['role']?.toString() ?? '';
    final universityId = invite['university_id']?.toString() ?? '';
    final status = invite['status']?.toString() ?? 'Pending';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(22)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.mark_email_read_outlined, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          SelectableText(email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          SelectableText('$role • $universityId', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
        ])),
        AccentPill(label: status, icon: Icons.hourglass_top_rounded),
      ]),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color? tone;
  const _StateMessage({required this.icon, required this.title, required this.body, this.tone});

  @override
  Widget build(BuildContext context) {
    final color = tone ?? AppColors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(22)),
      child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ])),
      ]),
    );
  }
}
