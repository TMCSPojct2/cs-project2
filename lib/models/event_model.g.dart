// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UniEvent _$UniEventFromJson(Map<String, dynamic> json) => UniEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  date: DateTime.parse(json['date'] as String),
  time: json['time'] as String,
  location: json['location'] as String,
  category: json['category'] as String,
  organizer: json['organizer'] as String,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$UniEventToJson(UniEvent instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
  'time': instance.time,
  'location': instance.location,
  'category': instance.category,
  'organizer': instance.organizer,
  'is_active': instance.isActive,
};
