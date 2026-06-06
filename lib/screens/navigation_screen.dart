import 'package:flutter/material.dart';
import '../data/role_context.dart';
import '../navigation/building_data.dart';
import '../navigation/wayfinding_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    final role = currentUserRole(context, fallback: UserRole.student);
    final bottomIndex = role == UserRole.visitor ? 1 : -1;
    return AppScaffold(
      appBar: AppBar(
        title: const Text('ملاحة الجامعة'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => _showTutorial(context),
          ),
        ],
      ),
      bottomNavigationBar: RoleBottomNav(
        currentIndex: bottomIndex,
        items: NavItems.forRole(role),
        role: role,
      ),
      body: _buildWayfinding(context),
    );
  }

  Widget _buildWayfinding(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.isNotEmpty) {
      final roomId = BuildingData.resolveRoomId(arg);
      if (roomId != null) return WayfindingScreen(initialDestinationId: roomId);
      return WayfindingScreen(initialDestinationQuery: arg);
    }
    return const WayfindingScreen();
  }

  void _showTutorial(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 8, bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const Text('كيفية استخدام خريطة الملاحة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF18222D))),
              const SizedBox(height: 20),
              _step('اختر نقطة البداية', 'ابحث عن الغرفة التي أنت فيها أو اضغط عليها في الخريطة.', Icons.my_location, AppColors.success),
              _step('اختر الوجهة', 'ابحث عن الغرفة التي تريد الوصول إليها واضغط عليها.', Icons.place, AppColors.danger),
              _step('اتبع السهم', 'سيظهر لك المسار الأمثل على الخريطة مع خطوات تفصيلية.', Icons.route, AppColors.primary),
              _step('غيّر الطابق', 'استخدم أزرار الطوابق على الجانب للتنقل بين طوابق المبنى.', Icons.layers, AppColors.secondary),
              const SizedBox(height: 20),
              const Text('دليل الألوان', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF18222D))),
              const SizedBox(height: 12),
              Wrap(spacing: 16, runSpacing: 12, children: [
                _legend(AppColors.success, 'نقطة البداية'),
                _legend(AppColors.danger, 'الوجهة'),
                _legend(AppColors.primary, 'المسار'),
                _legend(const Color(0xFF546E7A), 'ممر أو منطقة عبور'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _step(String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF18222D))),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7A8B))),
        ])),
      ]),
    );
  }

  static Widget _legend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF3D5166))),
    ]);
  }
}
