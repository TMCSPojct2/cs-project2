import 'package:json_annotation/json_annotation.dart';
part 'notification_model.g.dart';

@JsonSerializable()
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final String sender;
  final String type; // 'class', 'announcement', 'event', 'general'
  @JsonKey(defaultValue: false)
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

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}
