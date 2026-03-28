import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/announcement_model.dart';
import '../models/schedule_model.dart';
import '../models/notification_model.dart';

class DemoData {
  // ── Demo Users ──
  static const demoStudent = AppUser(
    id: 'u1',
    name: 'Yasser Ahmad',
    email: 's444006391@uqu.edu.sa',
    role: UserRole.student,
    department: 'Computer Engineering',
    studentId: '444006391',
    phone: '+966 55 123 4567',
  );

  static const demoFaculty = AppUser(
    id: 'u2',
    name: 'Dr. Khalid Alfalqi',
    email: 'kalfalqi@uqu.edu.sa',
    role: UserRole.faculty,
    department: 'Computer Engineering',
  );

  static const demoStaff = AppUser(
    id: 'u3',
    name: 'Ahmad Hassan',
    email: 'ahassan@staff.uqu.edu.sa',
    role: UserRole.staff,
    department: 'Student Affairs',
  );

  static const demoVisitor = AppUser(
    id: 'u4',
    name: 'Mohammed Ali',
    email: 'mali@gmail.com',
    role: UserRole.visitor,
  );

  static const allUsers = [demoStudent, demoFaculty, demoStaff, demoVisitor];

  // ── Demo Events ──
  static List<UniEvent> get events => [
    UniEvent(
      id: 'e1',
      title: 'Programming Competition',
      description: 'Annual programming contest for Computer Science and Engineering students. Teams of 3 compete in solving algorithmic challenges.',
      date: DateTime(2026, 4, 15),
      time: '09:00 AM - 03:00 PM',
      location: 'Hall 1.19, First Floor',
      category: 'Competition',
      organizer: 'CS Department',
    ),
    UniEvent(
      id: 'e2',
      title: 'Career Fair 2026',
      description: 'Meet top employers and explore internship and job opportunities. Open to all students and alumni.',
      date: DateTime(2026, 4, 20),
      time: '10:00 AM - 04:00 PM',
      location: 'Main Hall, Ground Floor',
      category: 'Career',
      organizer: 'Student Affairs',
    ),
    UniEvent(
      id: 'e3',
      title: 'AI & Machine Learning Workshop',
      description: 'Hands-on workshop covering fundamentals of machine learning, neural networks, and practical applications using Python.',
      date: DateTime(2026, 4, 10),
      time: '01:00 PM - 04:00 PM',
      location: 'Lab 2.08, Second Floor',
      category: 'Workshop',
      organizer: 'Dr. Khalid Alfalqi',
    ),
    UniEvent(
      id: 'e4',
      title: 'Open Day for New Students',
      description: 'Campus tour and orientation for prospective and newly admitted students. Includes facility tours and Q&A sessions.',
      date: DateTime(2026, 5, 1),
      time: '08:00 AM - 02:00 PM',
      location: 'South Entrance',
      category: 'Orientation',
      organizer: 'Admissions Office',
    ),
    UniEvent(
      id: 'e5',
      title: 'Cybersecurity Awareness Seminar',
      description: 'Learn about common cybersecurity threats, best practices for online safety, and protecting your digital identity.',
      date: DateTime(2026, 4, 25),
      time: '11:00 AM - 01:00 PM',
      location: 'Hall 1.03, First Floor',
      category: 'Seminar',
      organizer: 'IT Department',
    ),
    UniEvent(
      id: 'e6',
      title: 'Robotics Club Exhibition',
      description: 'Student robotics projects showcase. See autonomous robots, drones, and IoT projects built by engineering students.',
      date: DateTime(2026, 5, 5),
      time: '10:00 AM - 03:00 PM',
      location: 'Workshop B, Ground Floor',
      category: 'Exhibition',
      organizer: 'Robotics Club',
    ),
    UniEvent(
      id: 'e7',
      title: 'Final Exam Preparation Session',
      description: 'Review session covering exam strategies, time management, and stress reduction techniques for final exams.',
      date: DateTime(2026, 5, 10),
      time: '02:00 PM - 04:00 PM',
      location: 'Hall 1.20, First Floor',
      category: 'Academic',
      organizer: 'Academic Support Center',
    ),
    UniEvent(
      id: 'e8',
      title: 'Graduation Ceremony Rehearsal',
      description: 'Mandatory rehearsal for graduating students. Please arrive on time with your student ID.',
      date: DateTime(2026, 6, 1),
      time: '09:00 AM - 12:00 PM',
      location: 'Main Hall, Ground Floor',
      category: 'Ceremony',
      organizer: 'Registrar Office',
    ),
  ];

  // ── Demo Announcements ──
  static List<Announcement> get announcements => [
    Announcement(
      id: 'a1',
      title: 'Final Exam Schedule Published',
      content: 'The final examination schedule for Spring 2026 has been published. Please check your student portal for your individual exam timetable. Any conflicts must be reported to the Registrar Office within 3 days.',
      date: DateTime(2026, 3, 25),
      author: 'Registrar Office',
      target: 'All Students',
      isPinned: true,
    ),
    Announcement(
      id: 'a2',
      title: 'Library Extended Hours During Finals',
      content: 'The university library will extend its operating hours during the final exam period. New hours: 7:00 AM - 12:00 AM (midnight), effective April 28 through May 20.',
      date: DateTime(2026, 3, 26),
      author: 'Library Services',
      target: 'All Students',
    ),
    Announcement(
      id: 'a3',
      title: 'Scholarship Applications Now Open',
      content: 'Applications for the 2026-2027 academic excellence scholarship are now open. Eligible students must have a GPA of 4.0 or above. Deadline: April 30, 2026.',
      date: DateTime(2026, 3, 20),
      author: 'Financial Aid Office',
      target: 'All Students',
      isPinned: true,
    ),
    Announcement(
      id: 'a4',
      title: 'Maintenance Notice: Building C',
      content: 'Building C will undergo scheduled maintenance from April 5-7. All classes in Building C will be relocated. Check the updated schedule on the portal.',
      date: DateTime(2026, 3, 27),
      author: 'Facilities Management',
      target: 'All',
    ),
    Announcement(
      id: 'a5',
      title: 'New Course Registration Period',
      content: 'Registration for Fall 2026 courses opens on May 15. Priority registration for graduating seniors begins May 12. Please ensure your holds are cleared before registration.',
      date: DateTime(2026, 3, 22),
      author: 'Registrar Office',
      target: 'All Students',
    ),
    Announcement(
      id: 'a6',
      title: 'Campus Wi-Fi Upgrade',
      content: 'The campus Wi-Fi network will be upgraded to support higher speeds and more concurrent connections. Brief interruptions may occur between 2:00 AM - 5:00 AM on April 2.',
      date: DateTime(2026, 3, 28),
      author: 'IT Department',
      target: 'All',
    ),
  ];

  // ── Demo Schedule ──
  static const List<ClassSession> schedule = [
    ClassSession(
      id: 'c1', courseName: 'Software Engineering', courseCode: 'CS 421',
      instructor: 'Dr. Khalid Alfalqi', room: 'Hall 1.19',
      dayOfWeek: 0, startTime: '08:00', endTime: '09:30', creditHours: 3,
    ),
    ClassSession(
      id: 'c1b', courseName: 'Software Engineering', courseCode: 'CS 421',
      instructor: 'Dr. Khalid Alfalqi', room: 'Hall 1.19',
      dayOfWeek: 2, startTime: '08:00', endTime: '09:30', creditHours: 3,
    ),
    ClassSession(
      id: 'c2', courseName: 'Database Systems', courseCode: 'CS 342',
      instructor: 'Dr. Sara Ahmed', room: 'Hall 1.05',
      dayOfWeek: 0, startTime: '10:00', endTime: '11:30', creditHours: 3,
    ),
    ClassSession(
      id: 'c2b', courseName: 'Database Systems', courseCode: 'CS 342',
      instructor: 'Dr. Sara Ahmed', room: 'Hall 1.05',
      dayOfWeek: 2, startTime: '10:00', endTime: '11:30', creditHours: 3,
    ),
    ClassSession(
      id: 'c3', courseName: 'Computer Networks', courseCode: 'CS 331',
      instructor: 'Dr. Omar Faisal', room: 'Lab 2.08',
      dayOfWeek: 1, startTime: '09:00', endTime: '10:30', creditHours: 3,
    ),
    ClassSession(
      id: 'c3b', courseName: 'Computer Networks', courseCode: 'CS 331',
      instructor: 'Dr. Omar Faisal', room: 'Lab 2.08',
      dayOfWeek: 3, startTime: '09:00', endTime: '10:30', creditHours: 3,
    ),
    ClassSession(
      id: 'c4', courseName: 'Operating Systems', courseCode: 'CS 351',
      instructor: 'Dr. Ali Mansour', room: 'Hall 1.20',
      dayOfWeek: 1, startTime: '11:00', endTime: '12:30', creditHours: 3,
    ),
    ClassSession(
      id: 'c4b', courseName: 'Operating Systems', courseCode: 'CS 351',
      instructor: 'Dr. Ali Mansour', room: 'Hall 1.20',
      dayOfWeek: 3, startTime: '11:00', endTime: '12:30', creditHours: 3,
    ),
    ClassSession(
      id: 'c5', courseName: 'Artificial Intelligence', courseCode: 'CS 461',
      instructor: 'Dr. Nasser Bin Saleh', room: 'Hall 1.03',
      dayOfWeek: 4, startTime: '08:00', endTime: '10:30', creditHours: 3,
    ),
    ClassSession(
      id: 'c6', courseName: 'Web Development Lab', courseCode: 'CS 380',
      instructor: 'Dr. Khalid Alfalqi', room: 'Lab 2.03',
      dayOfWeek: 4, startTime: '11:00', endTime: '01:30', creditHours: 2,
    ),
  ];

  // ── Demo Notifications ──
  static List<AppNotification> get notifications => [
    AppNotification(
      id: 'n1',
      title: 'Assignment Due Tomorrow',
      message: 'CS 421 - Software Engineering: Project Phase 2 report is due tomorrow at 11:59 PM.',
      date: DateTime(2026, 3, 27, 14, 30),
      sender: 'Dr. Khalid Alfalqi',
      type: 'class',
    ),
    AppNotification(
      id: 'n2',
      title: 'Class Cancelled',
      message: 'CS 342 - Database Systems class on Tuesday March 31 is cancelled. A makeup class will be scheduled.',
      date: DateTime(2026, 3, 26, 09, 00),
      sender: 'Dr. Sara Ahmed',
      type: 'class',
    ),
    AppNotification(
      id: 'n3',
      title: 'New Event: Programming Competition',
      message: 'Registration is now open for the Annual Programming Competition on April 15. Register through the Events section.',
      date: DateTime(2026, 3, 25, 10, 00),
      sender: 'CS Department',
      type: 'event',
    ),
    AppNotification(
      id: 'n4',
      title: 'Grade Posted',
      message: 'Your midterm grade for CS 331 - Computer Networks has been posted. Check your academic record.',
      date: DateTime(2026, 3, 24, 16, 45),
      sender: 'Dr. Omar Faisal',
      type: 'class',
      isRead: true,
    ),
    AppNotification(
      id: 'n5',
      title: 'Scholarship Reminder',
      message: 'Reminder: The deadline for scholarship applications is April 30. Ensure all documents are submitted.',
      date: DateTime(2026, 3, 23, 08, 00),
      sender: 'Financial Aid Office',
      type: 'announcement',
      isRead: true,
    ),
    AppNotification(
      id: 'n6',
      title: 'Lab Report Feedback',
      message: 'Feedback is available for your CS 380 Web Development Lab report. Please review and resubmit if needed.',
      date: DateTime(2026, 3, 22, 11, 30),
      sender: 'Dr. Khalid Alfalqi',
      type: 'class',
      isRead: true,
    ),
  ];

  // ── GPA Grade Scale (Saudi 5.0 scale) ──
  static const Map<String, double> gradePoints = {
    'A+': 5.0,
    'A': 4.75,
    'B+': 4.5,
    'B': 4.0,
    'C+': 3.5,
    'C': 3.0,
    'D+': 2.5,
    'D': 2.0,
    'F': 1.0,
  };

  static const List<String> gradeOptions = [
    'A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F',
  ];

  static const List<int> creditOptions = [1, 2, 3, 4];

  // ── Event Categories ──
  static const List<String> eventCategories = [
    'All',
    'Academic',
    'Workshop',
    'Seminar',
    'Competition',
    'Career',
    'Orientation',
    'Exhibition',
    'Ceremony',
  ];
}
