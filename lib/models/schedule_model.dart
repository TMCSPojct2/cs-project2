import 'package:json_annotation/json_annotation.dart';
part 'schedule_model.g.dart';

@JsonSerializable()
class ClassSession {
  final String id;
  @JsonKey(name: 'course_name')
  final String courseName;
  @JsonKey(name: 'course_code')
  final String courseCode;
  final String instructor;
  final String room;
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek; // 0=Sun, 1=Mon...6=Sat
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'credit_hours')
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
