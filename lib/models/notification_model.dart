class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final String sender;
  final String type; // 'class', 'announcement', 'event', 'general'
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.sender,
    required this.type,
    this.isRead = false,
  });
}
