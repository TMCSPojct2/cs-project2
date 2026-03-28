import 'package:json_annotation/json_annotation.dart';
part 'announcement_model.g.dart';

@JsonSerializable()
class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String author;
  final String target;
  @JsonKey(name: 'is_pinned')
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

  factory Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);
  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);
}
