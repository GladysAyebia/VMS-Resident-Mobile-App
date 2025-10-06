// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resident_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Resident _$ResidentFromJson(Map<String, dynamic> json) => Resident(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  homeId: _homeIdFromJson(json['home'] as Map<String, dynamic>?),
  profilePicture: json['profilePicture'] as String?,
  role: json['role'] as String,
  status: json['status'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ResidentToJson(Resident instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'home': instance.homeId,
  'profilePicture': instance.profilePicture,
  'role': instance.role,
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
