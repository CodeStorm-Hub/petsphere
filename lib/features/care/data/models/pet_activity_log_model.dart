import 'package:flutter/material.dart';

/// A single exercise/activity log entry for a pet.
@immutable
class PetActivityLog {

  const PetActivityLog({
    this.id,
    required this.petId,
    required this.logDate,
    required this.activityType,
    this.durationMinutes = 0,
    this.intensity = 'moderate',
    this.notes,
  });

  factory PetActivityLog.fromJson(Map<String, dynamic> json) {
    return PetActivityLog(
      id: json['id'] as String?,
      petId: json['pet_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      activityType: json['activity_type'] as String,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      intensity: json['intensity'] as String? ?? 'moderate',
      notes: json['notes'] as String?,
    );
  }
  final String? id;
  final String petId;
  final DateTime logDate;
  final String activityType;
  final int durationMinutes;
  final String intensity;
  final String? notes;

  /// Human-readable label for the activity type.
  String get typeLabel => switch (activityType) {
    'walk' => 'Walk',
    'run' => 'Run',
    'play' => 'Play',
    'swim' => 'Swim',
    'training' => 'Training',
    'grooming' => 'Grooming',
    'social' => 'Social Time',
    'free_roam' => 'Free Roam',
    _ => 'Other',
  };

  /// Icon for the activity type.
  IconData get icon => switch (activityType) {
    'walk' => Icons.directions_walk,
    'run' => Icons.directions_run,
    'play' => Icons.sports_tennis,
    'swim' => Icons.pool,
    'training' => Icons.school,
    'grooming' => Icons.content_cut,
    'social' => Icons.people,
    'free_roam' => Icons.holiday_village_outlined,
    _ => Icons.fitness_center,
  };

  /// Color for the intensity level.
  Color get intensityColor => switch (intensity) {
    'low' => const Color(0xFF5BA3F5), // tertiary
    'high' => const Color(0xFFFFA726), // secondary
    _ => const Color(0xFF2979FF), // primary
  };

  Map<String, dynamic> toInsertJson() => {
    'pet_id': petId,
    'log_date':
        '${logDate.year.toString().padLeft(4, '0')}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}',
    'activity_type': activityType,
    'duration_minutes': durationMinutes,
    'intensity': intensity,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  Map<String, dynamic> toJson() => toInsertJson();

  PetActivityLog copyWith({
    String? id,
    String? petId,
    DateTime? logDate,
    String? activityType,
    int? durationMinutes,
    String? intensity,
    String? notes,
  }) => PetActivityLog(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    logDate: logDate ?? this.logDate,
    activityType: activityType ?? this.activityType,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    intensity: intensity ?? this.intensity,
    notes: notes ?? this.notes,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetActivityLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          logDate == other.logDate &&
          activityType == other.activityType &&
          durationMinutes == other.durationMinutes &&
          intensity == other.intensity &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      petId.hashCode ^
      logDate.hashCode ^
      activityType.hashCode ^
      durationMinutes.hashCode ^
      intensity.hashCode ^
      notes.hashCode;

  /// Activity types available for a given species.
  static List<String> typesForSpecies(String species) {
    return switch (species.toLowerCase()) {
      'dog' => ['walk', 'run', 'play', 'swim', 'training', 'grooming', 'other'],
      'cat' => ['play', 'training', 'grooming', 'social', 'other'],
      'bird' => ['social', 'free_roam', 'training', 'grooming', 'other'],
      'rabbit' => ['free_roam', 'play', 'grooming', 'social', 'other'],
      _ => ['walk', 'play', 'grooming', 'social', 'other'],
    };
  }
}
