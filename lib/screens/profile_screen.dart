import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _profile;
  final _lang = LanguageService.instance;

  @override
  void initState() {
    super.initState();
    _profile = Map<String, dynamic>.from(widget.profile);
    _lang.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _lang.removeListener(_rebuild);
    super.dispose();
  }

  void _showComingSoon(String featureKey) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('${_lang.tr(featureKey)} — ${_lang.tr('coming_soon')}!'),
          ],
        ),
        backgroundColor: NabihTheme.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editProfile() {
    final nameCtrl = TextEditingController(text: _profile['name'] ?? '');
    final deptCtrl = TextEditingController(text: _profile['department'] ?? '');
    final studentIdCtrl = TextEditingController(text: _profile['student_id'] ?? '');
    final phoneCtrl = TextEditingController(text: _profile['phone'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_lang.tr('edit_profile'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: _lang.tr('name'))),
              const SizedBox(height: 12),
              TextField(controller: deptCtrl, decoration: InputDecoration(labelText: _lang.tr('department'))),
              const SizedBox(height: 12),
              TextField(controller: studentIdCtrl, decoration: InputDecoration(labelText: _lang.tr('student_id'))),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: _lang.tr('phone'))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await AuthService.updateProfile(
                        name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
                        department: deptCtrl.text.trim().isNotEmpty ? deptCtrl.text.trim() : null,
                        studentId: studentIdCtrl.text.trim().isNotEmpty ? studentIdCtrl.text.trim() : null,
                        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                      );
                      setState(() {
                        if (nameCtrl.text.trim().isNotEmpty) _profile['name'] = nameCtrl.text.trim();
                        if (deptCtrl.text.trim().isNotEmpty) _profile['department'] = deptCtrl.text.trim();
                        if (studentIdCtrl.text.trim().isNotEmpty) _profile['student_id'] = studentIdCtrl.text.trim();
                        if (phoneCtrl.text.trim().isNotEmpty) _profile['phone'] = phoneCtrl.text.trim();
                      });
                      if (mounted) Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_lang.tr('profile_updated')), backgroundColor: NabihTheme.success),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${_lang.tr('profile_update_failed')}: $e'), backgroundColor: NabihTheme.error),
                      );
                    }
                  },
                  child: Text(_lang.tr('save_changes')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_lang.tr('sign_out_failed')}: $e'), backgroundColor: NabihTheme.error),
      );
    }
  }

  String get _roleLabel {
    final role = _profile['role'] ?? '';
    switch (role) {
      case 'student': return _lang.tr('student');
      case 'faculty': return _lang.tr('faculty');
      case 'staff':   return _lang.tr('staff');
      default:        return _lang.tr('visitor');
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile['name'] ?? '';
    final isStudent = _profile['role'] == 'student';

    return Scaffold(
      appBar: AppBar(
        title: Text(_lang.tr('profile')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => _lang.toggle(),
            tooltip: _lang.tr('switch_language'),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
            tooltip: _lang.tr('edit_profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: NabihTheme.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: NabihTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_roleLabel, style: const TextStyle(color: NabihTheme.primary, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
            _infoCard([
              _infoRow(Icons.email, _lang.tr('email'), _profile['email'] ?? ''),
              if (_profile['department'] != null && (_profile['department'] as String).isNotEmpty)
                _infoRow(Icons.business, _lang.tr('department'), _profile['department']),
              if (_profile['student_id'] != null && (_profile['student_id'] as String).isNotEmpty)
                _infoRow(Icons.badge, _lang.tr('student_id'), _profile['student_id']),
              if (_profile['phone'] != null && (_profile['phone'] as String).isNotEmpty)
                _infoRow(Icons.phone, _lang.tr('phone'), _profile['phone']),
            ]),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_lang.tr('quick_access'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            if (isStudent) ...[
              _menuTile(context, Icons.calculate, _lang.tr('gpa_calculator'), _lang.tr('gpa_calc_desc'), () {
                _showComingSoon('gpa_calculator');
              }, comingSoon: true),
              _menuTile(context, Icons.calendar_today, _lang.tr('my_schedule'), _lang.tr('my_schedule_desc'), () {
                _showComingSoon('my_schedule');
              }, comingSoon: true),
            ],
            _menuTile(context, Icons.campaign, _lang.tr('announcements'), _lang.tr('announcements_desc'), () {
              _showComingSoon('announcements');
            }, comingSoon: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, color: NabihTheme.error),
                label: Text(_lang.tr('sign_out'), style: const TextStyle(color: NabihTheme.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: NabihTheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('NABIH v2.0.0-preview', style: TextStyle(fontSize: 12, color: NabihTheme.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: NabihTheme.primary),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: NabihTheme.textLight)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap, {bool comingSoon = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: comingSoon
                ? Colors.grey.withValues(alpha: 0.1)
                : NabihTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: comingSoon ? NabihTheme.textLight : NabihTheme.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: comingSoon
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NabihTheme.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_lang.tr('soon'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: NabihTheme.warning)),
              )
            : const Icon(Icons.chevron_right, color: NabihTheme.textLight),
        onTap: onTap,
      ),
    );
  }
}
