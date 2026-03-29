import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/language_service.dart';

import 'dashboard_screen.dart';
import 'navigation_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  final Map<String, dynamic> profile;
  const HomeShell({super.key, required this.profile});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  final _lang = LanguageService.instance;

  late final List<Widget> _screens;

  static const _comingSoonTabs = {2, 3};

  @override
  void initState() {
    super.initState();
    _lang.addListener(_rebuild);
    _screens = [
      DashboardScreen(profile: widget.profile),
      const NavigationScreen(),
      _ComingSoonPage(titleKey: 'nav_events', icon: Icons.event_rounded),
      _ComingSoonPage(titleKey: 'nav_alerts', icon: Icons.notifications_rounded),
      ProfileScreen(profile: widget.profile),
    ];
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _lang.removeListener(_rebuild);
    super.dispose();
  }

  void _onTabTapped(int i) {
    if (_comingSoonTabs.contains(i)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.construction_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(_lang.tr('coming_soon_msg')),
            ],
          ),
          backgroundColor: NabihTheme.info,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return; // Stay on current page — feature not yet active
    }
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final tr = _lang.tr;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_lang.tr('ai_chat_coming_soon'))),
                ],
              ),
              backgroundColor: NabihTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        backgroundColor: NabihTheme.primary,
        tooltip: _lang.tr('ai_chat'),
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.dashboard_rounded), label: tr('nav_home')),
            BottomNavigationBarItem(icon: const Icon(Icons.map_rounded), label: tr('nav_navigate')),
            BottomNavigationBarItem(icon: const Icon(Icons.event_rounded), label: tr('nav_events')),
            BottomNavigationBarItem(icon: const Icon(Icons.notifications_rounded), label: tr('nav_alerts')),
            BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: tr('nav_profile')),
          ],
        ),
      ),
    );
  }
}

/// Placeholder page for coming-soon features
class _ComingSoonPage extends StatelessWidget {
  final String titleKey;
  final IconData icon;
  const _ComingSoonPage({required this.titleKey, required this.icon});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final title = lang.tr(titleKey);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: NabihTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: NabihTheme.primary),
            ),
            const SizedBox(height: 24),
            Text(lang.tr('coming_soon'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: NabihTheme.textPrimary)),
            const SizedBox(height: 8),
            Text('$title — ${lang.tr('feature_under_dev')}',
                style: const TextStyle(fontSize: 14, color: NabihTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(lang.tr('stay_tuned'),
                style: const TextStyle(fontSize: 14, color: NabihTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
