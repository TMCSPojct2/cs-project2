import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import 'gpa_calculator_screen.dart';
import 'schedule_screen.dart';
import 'announcements_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: NabihTheme.primary,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: NabihTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(user.roleLabel, style: const TextStyle(color: NabihTheme.primary, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
            _infoCard([
              _infoRow(Icons.email, 'Email', user.email),
              if (user.department != null) _infoRow(Icons.business, 'Department', user.department!),
              if (user.studentId != null) _infoRow(Icons.badge, 'Student ID', user.studentId!),
              if (user.phone != null) _infoRow(Icons.phone, 'Phone', user.phone!),
            ]),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Quick Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            if (user.role == UserRole.student) ...[
              _menuTile(context, Icons.calculate, 'GPA Calculator', 'Calculate your semester GPA', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GpaCalculatorScreen()));
              }),
              _menuTile(context, Icons.calendar_today, 'My Schedule', 'View your class timetable', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScheduleScreen(user: user)));
              }),
            ],
            _menuTile(context, Icons.campaign, 'Announcements', 'View university announcements', () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnnouncementsScreen(user: user)));
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
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
