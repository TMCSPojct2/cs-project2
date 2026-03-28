// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  date: DateTime.parse(json['date'] as String),
  author: json['author'] as String,
  target: json['target'] as String,
  isPinned: json['is_pinned'] as bool? ?? false,
);

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'date': instance.date.toIso8601String(),
      'author': instance.author,
      'target': instance.target,
      'is_pinned': instance.isPinned,
    };
