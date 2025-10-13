import 'package:json_annotation/json_annotation.dart';

part 'resident_model.g.dart';

@JsonSerializable()
class Resident {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;

  @JsonKey(name: 'home', fromJson: _homeIdFromJson)
  final String? homeId;

  final String? profilePicture;
  final String role;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Resident({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.homeId,
    this.profilePicture,
    required this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Resident.fromJson(Map<String, dynamic> json) =>
      _$ResidentFromJson(json);

  Map<String, dynamic> toJson() => _$ResidentToJson(this);

  // ✅ Computed property for full name
  String get fullName => '$firstName $lastName';
}

String? _homeIdFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return json['id'] as String?;
}
