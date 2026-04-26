import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pet Symptom
// ─────────────────────────────────────────────────────────────────────────────
@immutable
class PetSymptom {
  final String id;
  final String petId;
  final DateTime observedAt;
  final String symptomType;
  final String severity; // mild | moderate | severe
  final String? notes;
  final DateTime? resolvedAt;

  const PetSymptom({
    required this.id,
    required this.petId,
    required this.observedAt,
    required this.symptomType,
    this.severity = 'mild',
    this.notes,
    this.resolvedAt,
  });

  bool get isResolved => resolvedAt != null;

  Color get severityColor {
    switch (severity) {
      case 'severe':
        return Colors.redAccent;
      case 'moderate':
        return Colors.orange;
      default:
        return AppTheme.secondaryAccent;
    }
  }

  String get severityLabel {
    switch (severity) {
      case 'severe':
        return 'Severe';
      case 'moderate':
        return 'Moderate';
      default:
        return 'Mild';
    }
  }

  factory PetSymptom.fromJson(Map<String, dynamic> json) {
    return PetSymptom(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      observedAt: DateTime.parse(json['observed_at'] as String).toLocal(),
      symptomType: json['symptom_type'] as String,
      severity: json['severity'] as String? ?? 'mild',
      notes: json['notes'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toInsertJson(String petId) => {
        'pet_id': petId,
        'observed_at': observedAt.toUtc().toIso8601String(),
        'symptom_type': symptomType,
        'severity': severity,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
@immutable
class PetWeightLog {
  final String? id;
  final String petId;
  final DateTime logDate;
  final double weightLbs;
  final String? notes;

  const PetWeightLog({
    this.id,
    required this.petId,
    required this.logDate,
    required this.weightLbs,
    this.notes,
  });

  factory PetWeightLog.fromJson(Map<String, dynamic> json) {
    return PetWeightLog(
      id: json['id'] as String?,
      petId: json['pet_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      weightLbs: (json['weight_lbs'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toUpsertJson() => {
        'pet_id': petId,
        'log_date':
            '${logDate.year.toString().padLeft(4, '0')}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}',
        'weight_lbs': weightLbs,
        if (notes != null) 'notes': notes,
      };
}

@immutable
class PetVetAppointment {
  final String id;
  final String petId;
  final String title;
  final String? doctor;
  final DateTime scheduledAt;
  final String? notes;
  final String status;

  const PetVetAppointment({
    required this.id,
    required this.petId,
    required this.title,
    this.doctor,
    required this.scheduledAt,
    this.notes,
    this.status = 'scheduled',
  });

  factory PetVetAppointment.fromJson(Map<String, dynamic> json) {
    return PetVetAppointment(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      title: json['title'] as String,
      doctor: json['doctor'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String).toLocal(),
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'scheduled',
    );
  }
}

@immutable
class PetVaccination {
  final String id;
  final String petId;
  final String vaccineName;
  final String status; // scheduled | completed
  final DateTime? scheduledFor;
  final DateTime? completedOn;
  final String? notes;

  const PetVaccination({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.status,
    this.scheduledFor,
    this.completedOn,
    this.notes,
  });

  bool get isCompleted => status == 'completed';

  factory PetVaccination.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.parse(v as String);
    return PetVaccination(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      vaccineName: json['vaccine_name'] as String,
      status: json['status'] as String? ?? 'scheduled',
      scheduledFor: parseDate(json['scheduled_for']),
      completedOn: parseDate(json['completed_on']),
      notes: json['notes'] as String?,
    );
  }
}
