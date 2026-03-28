class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String author;
  final String target;
  final bool isPinned;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.author,
    required this.target,
    this.isPinned = false,
  });
}
