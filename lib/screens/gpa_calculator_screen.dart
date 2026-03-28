import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/demo_data.dart';

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final List<_CourseEntry> _courses = [
    _CourseEntry(),
    _CourseEntry(),
    _CourseEntry(),
  ];
  double? _gpa;

  void _addCourse() {
    if (_courses.length < 10) {
      setState(() => _courses.add(_CourseEntry()));
    }
  }

  void _removeCourse(int index) {
    if (_courses.length > 1) {
      setState(() {
        _courses.removeAt(index);
        _gpa = null;
      });
    }
  }

  void _calculate() {
    double totalPoints = 0;
    int totalCredits = 0;
    bool hasEmpty = false;

    for (final c in _courses) {
      if (c.name.isEmpty || c.grade == null || c.credits == null) {
        hasEmpty = true;
        break;
      }
      totalCredits += c.credits!;
      totalPoints += DemoData.gradePoints[c.grade!]! * c.credits!;
    }

    if (hasEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: NabihTheme.error),
      );
      return;
    }

    setState(() {
      _gpa = totalCredits > 0 ? totalPoints / totalCredits : 0;
    });
  }

  void _reset() {
    setState(() {
      _courses.clear();
      _courses.addAll([_CourseEntry(), _CourseEntry(), _CourseEntry()]);
      _gpa = null;
    });
  }

  Color _gpaColor(double gpa) {
    if (gpa >= 4.5) return NabihTheme.success;
    if (gpa >= 3.5) return NabihTheme.primary;
    if (gpa >= 2.5) return NabihTheme.accent;
    return NabihTheme.error;
  }

  String _gpaLabel(double gpa) {
    if (gpa >= 4.5) return 'Excellent';
    if (gpa >= 3.75) return 'Very Good';
    if (gpa >= 2.75) return 'Good';
    if (gpa >= 2.0) return 'Pass';
    return 'Fail';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset, tooltip: 'Reset'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NabihTheme.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: NabihTheme.secondary),
                        SizedBox(width: 8),
                        Expanded(child: Text('Saudi 5.0 GPA Scale  |  Up to 10 courses', style: TextStyle(fontSize: 12, color: NabihTheme.textSecondary))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_courses.length, (i) => _courseRow(i)),
                  const SizedBox(height: 12),
                  if (_courses.length < 10)
                    OutlinedButton.icon(
                      onPressed: _addCourse,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Course'),
                    ),
                  const SizedBox(height: 16),
                  if (_gpa != null) _gpaResult(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate GPA'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseRow(int index) {
    final course = _courses[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: NabihTheme.primary.withValues(alpha: 0.1),
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NabihTheme.primary)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (v) => course.name = v,
                    decoration: const InputDecoration(
                      hintText: 'Course Name',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                if (_courses.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _removeCourse(index),
                    color: NabihTheme.error,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 36),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: course.credits,
                    decoration: const InputDecoration(
                      hintText: 'Credits',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: DemoData.creditOptions.map((c) => DropdownMenuItem(value: c, child: Text('$c hr'))).toList(),
                    onChanged: (v) => setState(() { course.credits = v; _gpa = null; }),
                    style: const TextStyle(fontSize: 14, color: NabihTheme.textPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: course.grade,
                    decoration: const InputDecoration(
                      hintText: 'Grade',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: DemoData.gradeOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => setState(() { course.grade = v; _gpa = null; }),
                    style: const TextStyle(fontSize: 14, color: NabihTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gpaResult() {
    final color = _gpaColor(_gpa!);
    final label = _gpaLabel(_gpa!);
    int totalCredits = 0;
    double totalPoints = 0;
    for (final c in _courses) {
      if (c.credits != null && c.grade != null) {
        totalCredits += c.credits!;
        totalPoints += DemoData.gradePoints[c.grade!]! * c.credits!;
      }
    }

    return Card(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Semester GPA', style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              _gpa!.toStringAsFixed(2),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
            ),
            Text('out of 5.00', style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.7))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            ),
            const SizedBox(height: 12),
            Text('Total Credits: $totalCredits  |  Total Points: ${totalPoints.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 12, color: NabihTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CourseEntry {
  String name = '';
  int? credits;
  String? grade;
}
