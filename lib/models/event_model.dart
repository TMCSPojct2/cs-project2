import 'package:json_annotation/json_annotation.dart';
part 'event_model.g.dart';

@JsonSerializable()
class UniEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String category;
  final String organizer;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const UniEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.organizer,
    this.isActive = true,
  });

  factory UniEvent.fromJson(Map<String, dynamic> json) => _$UniEventFromJson(json);
  Map<String, dynamic> toJson() => _$UniEventToJson(this);
}
