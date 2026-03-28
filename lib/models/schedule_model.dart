import 'package:json_annotation/json_annotation.dart';
part 'schedule_model.g.dart';

class ClassSession {
  final String id;
  final String courseName;
  final String courseCode;
  final String instructor;
  final String room;
  final int dayOfWeek; // 0=Sun, 1=Mon...6=Sat
  final String startTime;
  final String endTime;
  final int creditHours;

  const ClassSession({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.instructor,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.creditHours,
  });

  factory ClassSession.fromJson(Map<String, dynamic> json) => _$ClassSessionFromJson(json);
  Map<String, dynamic> toJson() => _$ClassSessionToJson(this);

  String get dayName {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayOfWeek];
  }

  String get dayNameAr {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[dayOfWeek];
  }
}
