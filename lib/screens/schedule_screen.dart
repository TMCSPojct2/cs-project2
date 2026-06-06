import 'package:flutter/material.dart';
import '../data/app_content.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = currentUserRole(context);
    final bottomIndex = role == UserRole.student || role == UserRole.faculty ? 1 : 0;

    return AppScaffold(
      bottomNavigationBar: RoleBottomNav(currentIndex: bottomIndex, items: NavItems.forRole(role), role: role),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          BrandHeader(
            subtitle: LanguageController.text('Course Schedule', 'جدول المواد'),
            trailing: IconButton(onPressed: () => smartBack(context, currentUserRole(context)), icon: const Icon(Icons.arrow_back_rounded)),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(scheduleTitleForRole(role), style: Theme.of(context).textTheme.headlineMedium), const Spacer(), AccentPill(label: LanguageController.text('Spring Term', 'الفصل الربيعي'), icon: Icons.date_range_rounded)]),
              const SizedBox(height: 10),
              Text(scheduleIntroForRole(role), style: Theme.of(context).textTheme.bodyLarge),
            ]),
          ),
          const SizedBox(height: 20),
          _CourseScheduleCard(items: studentSchedule),
        ],
      ),
    );
  }
}



class _CourseScheduleCard extends StatelessWidget {
  final List<ScheduleItem> items;
  const _CourseScheduleCard({required this.items});

  static const _dayKeys = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس'];
  static const _dayLabelsAr = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];
  static const _dayLabelsEn = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(LanguageController.text('Course Schedule', 'جدول المواد'), style: Theme.of(context).textTheme.titleLarge),
      ),
      for (var i = 0; i < _dayKeys.length; i++)
        Builder(builder: (context) {
          final key = _dayKeys[i];
          final dayCourses = items
              .where((item) => item.days.split('•').map((d) => d.trim()).contains(key))
              .toList()
            ..sort((a, b) => a.time.compareTo(b.time));
          if (dayCourses.isEmpty) return const SizedBox.shrink();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Day header
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(30)),
                  child: Text((LanguageController.isArabic.value ? _dayLabelsAr : _dayLabelsEn)[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.3)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Divider(color: AppColors.primaryDark.withValues(alpha: 0.18), thickness: 1.5)),
              ]),
            ),
            // Courses for this day
            ...dayCourses.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 4, height: 52, decoration: BoxDecoration(color: item.accent, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(item.time, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Material(
                        color: item.accent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.pushNamed(context, '/navigation', arguments: item.place),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(children: [
                              const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item.place, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                            ]),
                          ),
                        ),
                      ),
                    ]),
                  ),
                )),
            const SizedBox(height: 8),
          ]);
        }),
    ]);
  }
}
