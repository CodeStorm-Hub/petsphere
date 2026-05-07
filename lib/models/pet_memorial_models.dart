import 'package:flutter/foundation.dart';

@immutable
class PetMemorialEntry {
  final String id;
  final String petId;
  final String petName;
  final String birthYear;
  final String passingYear;
  final String title;
  final String message;
  final String? petImageUrl;
  final String? messageImageUrl;
  final DateTime createdAt;

  const PetMemorialEntry({
    required this.id,
    required this.petId,
    required this.petName,
    required this.birthYear,
    required this.passingYear,
    required this.title,
    required this.message,
    this.petImageUrl,
    this.messageImageUrl,
    required this.createdAt,
  });

  factory PetMemorialEntry.fromJson(Map<String, dynamic> json) => PetMemorialEntry(
        id: json['id'] as String,
        petId: json['pet_id'] as String,
        petName: json['pet_name'] as String? ?? 'Angel',
        birthYear: json['birth_year'] as String? ?? '...',
        passingYear: json['passing_year'] as String? ?? '...',
        title: json['title'] as String? ?? 'Tribute',
        message: json['message'] as String? ?? '',
        petImageUrl: json['pet_image_url'] as String?,
        messageImageUrl: json['message_image_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'pet_id': petId,
        'pet_name': petName,
        'birth_year': birthYear,
        'passing_year': passingYear,
        'title': title,
        'message': message,
        'pet_image_url': petImageUrl,
        'message_image_url': messageImageUrl,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}
