import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'gpa_calculator_screen.dart';
import 'schedule_screen.dart';
import 'announcements_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _profile;

  @override
  void initState() {
    super.initState();
    _profile = Map<String, dynamic>.from(widget.profile);
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
              const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department')),
              const SizedBox(height: 12),
              TextField(controller: studentIdCtrl, decoration: const InputDecoration(labelText: 'Student ID')),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
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
                        const SnackBar(content: Text('Profile updated!'), backgroundColor: NabihTheme.success),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update: $e'), backgroundColor: NabihTheme.error),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
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
        SnackBar(content: Text('Sign out failed: $e'), backgroundColor: NabihTheme.error),
      );
    }
  }

  String get _roleLabel {
    final role = _profile['role'] ?? '';
    switch (role) {
      case 'student': return 'Student';
      case 'faculty': return 'Faculty';
      case 'staff': return 'Staff';
      default: return role.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile['name'] ?? '';
    final isStudent = _profile['role'] == 'student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
            tooltip: 'Edit Profile',
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
              _infoRow(Icons.email, 'Email', _profile['email'] ?? ''),
              if (_profile['department'] != null && (_profile['department'] as String).isNotEmpty)
                _infoRow(Icons.business, 'Department', _profile['department']),
              if (_profile['student_id'] != null && (_profile['student_id'] as String).isNotEmpty)
                _infoRow(Icons.badge, 'Student ID', _profile['student_id']),
              if (_profile['phone'] != null && (_profile['phone'] as String).isNotEmpty)
                _infoRow(Icons.phone, 'Phone', _profile['phone']),
            ]),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Quick Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            if (isStudent) ...[
              _menuTile(context, Icons.calculate, 'GPA Calculator', 'Calculate your semester GPA', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GpaCalculatorScreen()));
              }),
              _menuTile(context, Icons.calendar_today, 'My Schedule', 'View your class timetable', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScheduleScreen(profile: _profile)));
              }),
            ],
            _menuTile(context, Icons.campaign, 'Announcements', 'View university announcements', () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnnouncementsScreen(profile: _profile)));
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, color: NabihTheme.error),
                label: const Text('Sign Out', style: TextStyle(color: NabihTheme.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: NabihTheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('NABIH v1.0.0', style: TextStyle(fontSize: 12, color: NabihTheme.textLight)),
            const Text('Umm Al Qura University', style: TextStyle(fontSize: 12, color: NabihTheme.textLight)),
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

  Widget _menuTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: NabihTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: NabihTheme.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: NabihTheme.textLight),
        onTap: onTap,
      ),
    );
  }
}
