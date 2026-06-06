import 'package:flutter/material.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/gpa_service.dart';
import '../services/schedule_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class GpaScreen extends StatefulWidget {
  const GpaScreen({super.key});

  @override
  State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> {
  final List<_GpaRow> _rows = [
    _GpaRow(course: courses.first, grade: 'A'),
    _GpaRow(course: courses[1], grade: 'B+'),
    _GpaRow(course: courses[2], grade: 'B+'),
  ];
  bool _showGpa = true;
  bool _saving = false;

  double get _gpa {
    final totalCredits = _rows.fold<int>(0, (sum, row) => sum + row.credits);
    if (totalCredits == 0) return 0;
    final totalPoints = _rows.fold<double>(0, (sum, row) => sum + (_gradePoints[row.grade] ?? 0) * row.credits);
    return totalPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    final role = currentUserRole(context);
    return AppScaffold(
      bottomNavigationBar: RoleBottomNav(currentIndex: 0, items: NavItems.forRole(role), role: role),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          BrandHeader(
            subtitle: LanguageController.text('Academic planning support', 'دعم التخطيط الأكاديمي'),
            trailing: IconButton(onPressed: () => smartBack(context, currentUserRole(context)), icon: const Icon(Icons.arrow_back_rounded)),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            gradient: const LinearGradient(colors: [Color(0xFF152B44), Color(0xFF26476D)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AccentPill(label: LanguageController.text('GPA CALCULATOR', 'حاسبة المعدل'), icon: Icons.calculate_outlined, filled: true),
              const SizedBox(height: 16),
              Text(LanguageController.text('Estimate performance before final submission.', 'قدّر الأداء قبل ظهور النتائج النهائية.'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              Text(LanguageController.text('Choose each course and grade. The calculated GPA is saved and shown on the student home screen.', 'اختر كل مقرر والدرجة. يتم حفظ المعدل المحسوب وعرضه في الصفحة الرئيسية للطالب.'), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(LanguageController.text('Current Semester Inputs', 'مدخلات الفصل الحالي'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ..._rows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CourseField(
                    row: row,
                    canDelete: _rows.length > 1,
                    onCourseChanged: (course) => setState(() => row.course = course),
                    onGradeChanged: (grade) => setState(() => row.grade = grade),
                    onCustomNameChanged: (name) => setState(() => row.customName = name),
                    onCustomCreditsChanged: (credits) => setState(() => row.customCredits = credits),
                    onRemove: () => setState(() => _rows.removeAt(index)),
                  ),
                );
              }),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: GradientButton(label: _saving ? LanguageController.text('Saving...', 'جاري الحفظ...') : LanguageController.text('Calculate & Save', 'احسب واحفظ'), compact: true, icon: Icons.calculate_outlined, onPressed: _saving ? null : _saveGpa)),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(onPressed: _addCourse, child: Text(LanguageController.text('Add Course', 'إضافة مقرر')))),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            gradient: const LinearGradient(colors: [Color(0xFFF8F6F1), Colors.white]),
            child: Row(children: [
              Container(width: 58, height: 58, decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.calculate_outlined, color: AppColors.secondary)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(LanguageController.text('Projected GPA', 'المعدل المتوقع'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(_showGpa ? _gpa.toStringAsFixed(2) : '****', style: Theme.of(context).textTheme.headlineMedium),
              ])),
              IconButton(onPressed: () => setState(() => _showGpa = !_showGpa), icon: Icon(_showGpa ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.primary)),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGpa() async {
    setState(() => _saving = true);
    try {
      final role = currentUserRole(context);
      final messenger = ScaffoldMessenger.of(context);
      await GpaService.instance.saveGpa(
        gpa: _gpa,
        courses: _rows.map((row) => {'course': row.displayName, 'credits': row.credits, 'grade': row.grade}).toList(),
      );
      for (final row in _rows) {
        await ScheduleService.instance.addItem(
          role: role,
          title: row.displayName,
          timeRange: LanguageController.text('Time not set', 'لم يتم تحديد الوقت'),
          meta: LanguageController.text('GPA entry', 'إدخال المعدل'),
          location: LanguageController.text('Location not set', 'لم يتم تحديد الموقع'),
        );
      }
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(LanguageController.text('GPA saved and courses added to schedule', 'تم حفظ المعدل وإضافة المقررات للجدول'))));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Unable to save GPA now.', 'تعذر حفظ المعدل الآن.'))));
    }
  }

  void _addCourse() {
    if (_rows.length < courses.length) {
      setState(() => _rows.add(_GpaRow(course: courses[_rows.length], grade: 'A')));
    } else {
      setState(() => _rows.add(_GpaRow(grade: 'A')));
    }
  }
}

class _CourseOption {
  final String englishName;
  final String arabicName;
  final int credits;
  const _CourseOption(this.englishName, this.arabicName, this.credits);
  String get name => LanguageController.text(englishName, arabicName);
}

class _GpaRow {
  _CourseOption? course;
  String customName;
  int customCredits;
  String grade;
  _GpaRow({this.course, this.customName = '', this.customCredits = 3, required this.grade});
  bool get isCustom => course == null;
  String get displayName => isCustom ? customName : course!.name;
  int get credits => isCustom ? customCredits : course!.credits;
}

const courses = [
  _CourseOption('Software Engineering', 'هندسة البرمجيات', 3),
  _CourseOption('Networks Lab', 'معمل الشبكات', 1),
  _CourseOption('Human Computer Interaction', 'التفاعل بين الإنسان والحاسوب', 3),
  _CourseOption('Database Systems', 'نظم قواعد البيانات', 3),
  _CourseOption('Artificial Intelligence', 'الذكاء الاصطناعي', 3),
  _CourseOption('Graduation Project', 'مشروع التخرج', 4),
];

const _gradePoints = {
  'A+': 4.0,
  'A': 3.75,
  'B+': 3.5,
  'B': 3.0,
  'C+': 2.5,
  'C': 2.0,
  'D+': 1.5,
  'D': 1.0,
  'F': 0.0,
};

class _CourseField extends StatelessWidget {
  final _GpaRow row;
  final bool canDelete;
  final ValueChanged<_CourseOption> onCourseChanged;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onCustomNameChanged;
  final ValueChanged<int> onCustomCreditsChanged;
  final VoidCallback onRemove;
  const _CourseField({
    required this.row,
    required this.canDelete,
    required this.onCourseChanged,
    required this.onGradeChanged,
    required this.onCustomNameChanged,
    required this.onCustomCreditsChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(LanguageController.text('Course Entry', 'إدخال مقرر'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16))),
          if (canDelete) IconButton(onPressed: onRemove, icon: const Icon(Icons.close_rounded)),
        ]),
        const SizedBox(height: 12),
        if (row.isCustom) ...[
          TextField(
            decoration: InputDecoration(
              labelText: LanguageController.text('Course Name', 'اسم المادة'),
              prefixIcon: const Icon(Icons.menu_book_outlined),
            ),
            onChanged: onCustomNameChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: LanguageController.text('Credit Hours', 'عدد الساعات'),
              prefixIcon: const Icon(Icons.timer_outlined),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => onCustomCreditsChanged(int.tryParse(v) ?? 3),
          ),
        ] else
          DropdownButtonFormField<_CourseOption>(
            initialValue: row.course,
            isExpanded: true,
            decoration: InputDecoration(labelText: LanguageController.text('Course', 'المقرر')),
            items: courses.map((course) => DropdownMenuItem(value: course, child: Text('${course.name} • ${course.credits} ${LanguageController.text('cr', 'ساعة')}', overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (value) {
              if (value != null) onCourseChanged(value);
            },
          ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: row.grade,
          decoration: InputDecoration(labelText: LanguageController.text('Expected Grade', 'الدرجة المتوقعة')),
          items: _gradePoints.keys.map((grade) => DropdownMenuItem(value: grade, child: Text(grade))).toList(),
          onChanged: (value) {
            if (value != null) onGradeChanged(value);
          },
        ),
      ]),
    );
  }
}
