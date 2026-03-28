// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: userRoleFromString(json['role'] as String),
  department: json['department'] as String?,
  studentId: json['studentId'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': userRoleToString(instance.role),
  'department': instance.department,
  'studentId': instance.studentId,
  'phone': instance.phone,
};
