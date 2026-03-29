import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/language_service.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> profile;
  const DashboardScreen({super.key, required this.profile});

  LanguageService get _lang => LanguageService.instance;

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('$feature — ${_lang.tr('coming_soon')}!'),
          ],
        ),
        backgroundColor: NabihTheme.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final name = (profile['name'] as String?) ?? '';
    final role = (profile['role'] as String?) ?? '';
    final firstName = name.isNotEmpty ? name.split(' ').first : '';
    final roleLabel = switch (role) {
      'student' => _lang.tr('student'),
      'faculty' => _lang.tr('faculty'),
      'staff'   => _lang.tr('staff'),
      _         => role.isNotEmpty ? _lang.tr('visitor') : '',
    };

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: NabihTheme.primary,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_lang.tr('hello')}, $firstName!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: NabihTheme.textPrimary)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: NabihTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(roleLabel,
                    style: const TextStyle(fontSize: 12, color: NabihTheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: NabihTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
              child: Text('N',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: NabihTheme.primary))),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final tr = _lang.tr;
    final actions = <_QuickAction>[
      _QuickAction(tr('navigate'), Icons.map_rounded, NabihTheme.primary, null, true),
      _QuickAction(tr('schedule'), Icons.calendar_today_rounded, NabihTheme.secondary, tr('feat_schedule'), false),
      if (profile['role'] == 'student')
        _QuickAction(tr('gpa_calc'), Icons.calculate_rounded, NabihTheme.accent, tr('feat_gpa'), false),
      _QuickAction(tr('announce'), Icons.campaign_rounded, const Color(0xFF6C5CE7), tr('feat_announcements'), false),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final a = actions[i];
          return GestureDetector(
            onTap: () {
              if (a.isActive) {
                // Navigate tab — no-op, user can tap Navigate in bottom nav
              } else {
                _showComingSoon(context, a.comingSoonLabel!);
              }
            },
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                color: a.isActive
                    ? a.color.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: a.isActive
                      ? a.color.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(a.icon, color: a.isActive ? a.color : NabihTheme.textLight, size: 32),
                  const SizedBox(height: 6),
                  Text(a.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: a.isActive ? a.color : NabihTheme.textLight,
                      )),
                  if (!a.isActive) ...[
                    const SizedBox(height: 2),
                    Text(_lang.tr('soon'), style: const TextStyle(fontSize: 9, color: NabihTheme.textLight)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String? comingSoonLabel;
  final bool isActive;
  const _QuickAction(this.label, this.icon, this.color, this.comingSoonLabel, this.isActive);
}
