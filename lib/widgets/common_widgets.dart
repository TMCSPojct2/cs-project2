import 'package:flutter/material.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/notifications_service.dart';
import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .3),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(.12), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      padding: EdgeInsets.all(size * .12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * .22),
        child: Image.asset('assets/branding/nabih_mark.png', fit: BoxFit.contain),
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final double topSpacing;
  const BrandHeader({
    super.key,
    this.title = 'NABIH',
    this.subtitle = 'Smart University Assistant',
    this.trailing,
    this.topSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topSpacing),
      child: Row(
        children: [
          const BrandMark(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LanguageController.translateRaw(title), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(LanguageController.translateRaw(subtitle), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color? borderColor;
  const SurfaceCard({super.key, required this.child, this.padding, this.gradient, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.card : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor ?? AppColors.line.withOpacity(.9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 30, offset: const Offset(0, 18)),
        ],
      ),
      child: child,
    );
  }
}

class AccentPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;
  const AccentPill({super.key, required this.label, this.icon, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColors.primary : AppColors.mist;
    final fg = filled ? Colors.white : AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: filled ? Colors.transparent : AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
          ],
          Text(LanguageController.translateRaw(label), style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool compact;
  const GradientButton({super.key, required this.label, this.onPressed, this.icon = Icons.arrow_forward_rounded, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: compact ? 14 : 18),
          decoration: BoxDecoration(
            gradient: onPressed == null
                ? const LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFFBDBDBD)])
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF2A7C77)],
                  ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: onPressed == null
                ? []
                : [BoxShadow(color: AppColors.primary.withOpacity(.22), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
              const SizedBox(width: 10),
              Icon(icon, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(LanguageController.translateRaw(title), style: Theme.of(context).textTheme.titleLarge)),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(LanguageController.translateRaw(action!), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? tone;
  final VoidCallback? onTap;
  const InfoTile({super.key, required this.icon, required this.title, required this.subtitle, this.tone, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = tone ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LanguageController.translateRaw(title), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(LanguageController.translateRaw(subtitle), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}


String homeRouteForRole(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return '/faculty-home';
    case UserRole.admin:
      return '/admin-home';
    case UserRole.visitor:
      return '/visitor-home';
    case UserRole.student:
      return '/student-home';
  }
}

void smartBack(BuildContext context, UserRole role) {
  if (Navigator.canPop(context)) {
    Navigator.maybePop(context);
    return;
  }
  Navigator.pushReplacementNamed(context, homeRouteForRole(role), arguments: role);
}

class NotifBell extends StatefulWidget {
  final String route;
  final Object? arguments;
  const NotifBell({super.key, required this.route, this.arguments});
  @override
  State<NotifBell> createState() => _NotifBellState();
}

class _NotifBellState extends State<NotifBell> {
  @override
  void initState() {
    super.initState();
    NotificationsService.instance.refreshUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationsService.unreadCount,
      builder: (context, count, _) => IconButton(
        onPressed: () => Navigator.pushNamed(context, widget.route, arguments: widget.arguments),
        icon: Stack(clipBehavior: Clip.none, children: [
          const Icon(Icons.notifications_none_rounded),
          if (count > 0)
            Positioned(
              right: -2, top: -2,
              child: Container(
                width: 9, height: 9,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class RoleBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<({IconData icon, String label, String route})> items;
  final UserRole? role;
  const RoleBottomNav({super.key, required this.currentIndex, required this.items, this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 28, offset: const Offset(0, 14))],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final active = i == currentIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                if (!active) {
                  Navigator.pushNamed(context, item.route, arguments: role);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.mist,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item.icon, color: active ? Colors.white : AppColors.muted, size: 21),
                    ),
                    const SizedBox(height: 6),
                    Text(LanguageController.translateRaw(item.label), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? AppColors.primaryDark : AppColors.muted)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NavItems {
  static const student = [
    (icon: Icons.home_rounded, label: 'Home', route: '/student-home'),
    (icon: Icons.calendar_month_rounded, label: 'Schedule', route: '/schedule'),
    (icon: Icons.notifications_none_rounded, label: 'Alerts', route: '/notifications'),
    (icon: Icons.person_outline_rounded, label: 'Profile', route: '/profile'),
  ];

  static const faculty = [
    (icon: Icons.home_rounded, label: 'Home', route: '/faculty-home'),
    (icon: Icons.send_outlined, label: 'Notify', route: '/faculty-notify'),
    (icon: Icons.notifications_none_rounded, label: 'Alerts', route: '/notifications'),
    (icon: Icons.person_outline_rounded, label: 'Profile', route: '/profile'),
  ];

  static const admin = [
    (icon: Icons.dashboard_outlined, label: 'Home', route: '/admin-home'),
    (icon: Icons.campaign_outlined, label: 'Publish', route: '/announcement'),
    (icon: Icons.event_available_rounded, label: 'Events', route: '/admin-event'),
    (icon: Icons.person_outline_rounded, label: 'Profile', route: '/profile'),
  ];

  static const visitor = [
    (icon: Icons.home_rounded, label: 'Home', route: '/visitor-home'),
    (icon: Icons.map_outlined, label: 'Map', route: '/navigation'),
    (icon: Icons.auto_awesome_outlined, label: 'Assistant', route: '/assistant'),
    (icon: Icons.event_outlined, label: 'Events', route: '/admin-event'),
  ];

  static List<({IconData icon, String label, String route})> forRole(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return faculty;
      case UserRole.admin:
        return admin;
      case UserRole.visitor:
        return visitor;
      case UserRole.student:
        return student;
    }
  }
}
