// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassSession _$ClassSessionFromJson(Map<String, dynamic> json) => ClassSession(
  id: json['id'] as String,
  courseName: json['course_name'] as String,
  courseCode: json['course_code'] as String,
  instructor: json['instructor'] as String,
  room: json['room'] as String,
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  creditHours: (json['credit_hours'] as num).toInt(),
);

Map<String, dynamic> _$ClassSessionToJson(ClassSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_name': instance.courseName,
      'course_code': instance.courseCode,
      'instructor': instance.instructor,
      'room': instance.room,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'credit_hours': instance.creditHours,
    };
