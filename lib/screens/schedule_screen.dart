import 'package:flutter/material.dart';
import '../data/app_content.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/schedule_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<List<ScheduleItem>> _itemsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _itemsFuture = ScheduleService.instance.listSchedule(currentUserRole(context));
  }

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
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: () => _openAddClassSheet(role), child: Text(scheduleSecondaryActionForRole(role))),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          _CourseScheduleCard(items: studentSchedule),
          const SizedBox(height: 20),
          FutureBuilder<List<ScheduleItem>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              final items = snapshot.data ?? <ScheduleItem>[];
              if (items.isEmpty) return const SizedBox.shrink();
              return Column(children: [
                SurfaceCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(LanguageController.text('My Added Classes', 'مواد مضافة'), style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _ScheduleListCard(item: item))),
                  ]),
                ),
              ]);
            },
          ),
        ],
      ),
    );
  }

  void _reload(UserRole role) => setState(() => _itemsFuture = ScheduleService.instance.listSchedule(role));

  void _openAddClassSheet(UserRole role) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final sectionController = TextEditingController();
    final placeController = TextEditingController();
    var saving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(22, 22, 22, MediaQuery.of(context).viewInsets.bottom + 22),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(role == UserRole.faculty ? LanguageController.text('Add Office Hour', 'إضافة ساعة مكتبية') : LanguageController.text('Add Class', 'إضافة محاضرة'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              TextField(controller: titleController, decoration: InputDecoration(labelText: LanguageController.text('Title', 'العنوان'), prefixIcon: const Icon(Icons.menu_book_outlined))),
              const SizedBox(height: 12),
              TextField(controller: timeController, decoration: InputDecoration(labelText: LanguageController.text('Time', 'الوقت'), hintText: '09:00 - 10:15', prefixIcon: const Icon(Icons.schedule_rounded))),
              const SizedBox(height: 12),
              TextField(controller: sectionController, decoration: InputDecoration(labelText: LanguageController.text('Section / Group', 'الشعبة / المجموعة'), prefixIcon: const Icon(Icons.groups_outlined))),
              const SizedBox(height: 12),
              TextField(controller: placeController, decoration: InputDecoration(labelText: LanguageController.text('Location', 'الموقع'), prefixIcon: const Icon(Icons.place_outlined))),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;
                          setSheetState(() => saving = true);
                          try {
                            await ScheduleService.instance.addItem(
                              role: role,
                              title: title,
                              timeRange: timeController.text.trim().isEmpty ? LanguageController.text('Time not set', 'لم يتم تحديد الوقت') : timeController.text.trim(),
                              meta: sectionController.text.trim().isEmpty ? LanguageController.text('Manual entry', 'إدخال يدوي') : sectionController.text.trim(),
                              location: placeController.text.trim().isEmpty ? LanguageController.text('Location not set', 'لم يتم تحديد الموقع') : placeController.text.trim(),
                            );
                            if (!mounted) return;
                            Navigator.pop(sheetContext);
                            _reload(role);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Schedule item saved', 'تم حفظ عنصر الجدول'))));
                          } catch (_) {
                            setSheetState(() => saving = false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Unable to save schedule item now.', 'تعذر حفظ عنصر الجدول الآن.'))));
                          }
                        },
                  child: Text(saving ? LanguageController.text('Saving...', 'جاري الحفظ...') : LanguageController.text('Save', 'حفظ')),
                ),
              ),
            ]),
          );
        });
      },
    );
  }
}

class _ScheduleListCard extends StatelessWidget {
  final ScheduleItem item;
  const _ScheduleListCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 12, height: 90, decoration: BoxDecoration(color: item.accent, borderRadius: BorderRadius.circular(999))),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(item.meta, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text(item.time, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(item.place, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.ink)),
          ]),
        ),
      ]),
    );
  }
}

class _CourseScheduleCard extends StatelessWidget {
  final List<ScheduleItem> items;
  const _CourseScheduleCard({required this.items});

  static const _dayKeys = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس'];
  static const _dayLabels = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];

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
                  child: Text(_dayLabels[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.3)),
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
