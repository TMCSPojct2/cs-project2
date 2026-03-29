import 'package:flutter_test/flutter_test.dart';
import '../lib/models/schedule_model.dart';

void main() {
  group('ClassSession', () {
    test('fromJson and toJson work correctly', () {
      final json = {
        'id': 'c1',
        'course_name': 'Software Engineering',
        'course_code': 'CS 421',
        'instructor': 'Dr. Khalid Alfalqi',
        'room': 'Hall 1.19',
        'day_of_week': 0,
        'start_time': '08:00',
        'end_time': '09:30',
        'credit_hours': 3,
      };
      final session = ClassSession.fromJson(json);
      expect(session.id, 'c1');
      expect(session.courseName, 'Software Engineering');
      expect(session.courseCode, 'CS 421');
      expect(session.instructor, 'Dr. Khalid Alfalqi');
      expect(session.room, 'Hall 1.19');
      expect(session.dayOfWeek, 0);
      expect(session.startTime, '08:00');
      expect(session.endTime, '09:30');
      expect(session.creditHours, 3);
      // toJson round-trip
      expect(session.toJson(), json);
    });
  });
}
