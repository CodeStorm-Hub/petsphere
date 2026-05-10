import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_theme.dart';

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
        return const Color(0xFFE85D75);
      case 'moderate':
        return AppTheme.primaryAccent;
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'pet_id': petId,
    'observed_at': observedAt.toUtc().toIso8601String(),
    'symptom_type': symptomType,
    'severity': severity,
    if (notes != null) 'notes': notes,
    if (resolvedAt != null) 'resolved_at': resolvedAt!.toUtc().toIso8601String(),
  };

  PetSymptom copyWith({
    String? id,
    String? petId,
    DateTime? observedAt,
    String? symptomType,
    String? severity,
    String? notes,
    DateTime? resolvedAt,
    bool clearResolved = false,
  }) => PetSymptom(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    observedAt: observedAt ?? this.observedAt,
    symptomType: symptomType ?? this.symptomType,
    severity: severity ?? this.severity,
    notes: notes ?? this.notes,
    resolvedAt: clearResolved ? null : (resolvedAt ?? this.resolvedAt),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetSymptom &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          observedAt == other.observedAt &&
          symptomType == other.symptomType &&
          severity == other.severity &&
          notes == other.notes &&
          resolvedAt == other.resolvedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      petId.hashCode ^
      observedAt.hashCode ^
      symptomType.hashCode ^
      severity.hashCode ^
      notes.hashCode ^
      resolvedAt.hashCode;
}

// ─────────────────────────────────────────────────────────────────────────────
@immutable
class PetWeightLog {
  final String? id;
  final String petId;
  final DateTime logDate;
  final double weightLbs;
  final String? notes;
  final int? bcsScore; // 1–9 Body Condition Score
  final String unit; // lbs | kg

  const PetWeightLog({
    this.id,
    required this.petId,
    required this.logDate,
    required this.weightLbs,
    this.notes,
    this.bcsScore,
    this.unit = 'lbs',
  });

  String get bcsLabel {
    switch (bcsScore) {
      case 1:
      case 2:
        return 'Very Thin';
      case 3:
        return 'Thin';
      case 4:
        return 'Underweight';
      case 5:
        return 'Ideal';
      case 6:
        return 'Slightly Overweight';
      case 7:
        return 'Overweight';
      case 8:
        return 'Obese';
      case 9:
        return 'Severely Obese';
      default:
        return 'Not set';
    }
  }

  factory PetWeightLog.fromJson(Map<String, dynamic> json) {
    return PetWeightLog(
      id: json['id'] as String?,
      petId: json['pet_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      weightLbs: (json['weight_lbs'] as num).toDouble(),
      notes: json['notes'] as String?,
      bcsScore: json['bcs_score'] as int?,
      unit: json['unit'] as String? ?? 'lbs',
    );
  }

  Map<String, dynamic> toUpsertJson() => {
    'pet_id': petId,
    'log_date':
        '${logDate.year.toString().padLeft(4, '0')}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}',
    'weight_lbs': weightLbs,
    if (notes != null) 'notes': notes,
    if (bcsScore != null) 'bcs_score': bcsScore,
    'unit': unit,
  };

  Map<String, dynamic> toJson() => toUpsertJson();

  PetWeightLog copyWith({
    String? id,
    String? petId,
    DateTime? logDate,
    double? weightLbs,
    String? notes,
    int? bcsScore,
    String? unit,
  }) => PetWeightLog(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    logDate: logDate ?? this.logDate,
    weightLbs: weightLbs ?? this.weightLbs,
    notes: notes ?? this.notes,
    bcsScore: bcsScore ?? this.bcsScore,
    unit: unit ?? this.unit,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetWeightLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          logDate == other.logDate &&
          weightLbs == other.weightLbs &&
          notes == other.notes &&
          bcsScore == other.bcsScore &&
          unit == other.unit;

  @override
  int get hashCode =>
      id.hashCode ^
      petId.hashCode ^
      logDate.hashCode ^
      weightLbs.hashCode ^
      notes.hashCode ^
      bcsScore.hashCode ^
      unit.hashCode;
}

@immutable
class PetVetAppointment {
  final String id;
  final String petId;
  final String title;
  final String? doctor;
  final DateTime scheduledAt;
  final String? notes;
  final String status; // scheduled | completed | cancelled
  final String
  appointmentType; // routine | emergency | specialist | dental | surgery | follow_up
  final String? location;
  final double? cost;

  const PetVetAppointment({
    required this.id,
    required this.petId,
    required this.title,
    this.doctor,
    required this.scheduledAt,
    this.notes,
    this.status = 'scheduled',
    this.appointmentType = 'routine',
    this.location,
    this.cost,
  });

  int get daysUntil => scheduledAt.difference(DateTime.now()).inDays;

  String get appointmentTypeLabel {
    switch (appointmentType) {
      case 'emergency':
        return 'Emergency';
      case 'specialist':
        return 'Specialist';
      case 'dental':
        return 'Dental';
      case 'surgery':
        return 'Surgery';
      case 'follow_up':
        return 'Follow-up';
      default:
        return 'Routine';
    }
  }

  factory PetVetAppointment.fromJson(Map<String, dynamic> json) {
    return PetVetAppointment(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      title: json['title'] as String,
      doctor: json['doctor'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String).toLocal(),
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'scheduled',
      appointmentType: json['appointment_type'] as String? ?? 'routine',
      location: json['location'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toUpsertJson() => {
    if (id.isNotEmpty) 'id': id,
    'pet_id': petId,
    'title': title,
    if (doctor != null) 'doctor': doctor,
    'scheduled_at': scheduledAt.toUtc().toIso8601String(),
    if (notes != null) 'notes': notes,
    'status': status,
    'appointment_type': appointmentType,
    if (location != null) 'location': location,
    if (cost != null) 'cost': cost,
  };

  Map<String, dynamic> toJson() => toUpsertJson();

  PetVetAppointment copyWith({
    String? id,
    String? petId,
    String? title,
    String? doctor,
    DateTime? scheduledAt,
    String? notes,
    String? status,
    String? appointmentType,
    String? location,
    double? cost,
  }) => PetVetAppointment(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    title: title ?? this.title,
    doctor: doctor ?? this.doctor,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    notes: notes ?? this.notes,
    status: status ?? this.status,
    appointmentType: appointmentType ?? this.appointmentType,
    location: location ?? this.location,
    cost: cost ?? this.cost,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetVetAppointment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          title == other.title &&
          doctor == other.doctor &&
          scheduledAt == other.scheduledAt &&
          notes == other.notes &&
          status == other.status &&
          appointmentType == other.appointmentType &&
          location == other.location &&
          cost == other.cost;

  @override
  int get hashCode =>
      id.hashCode ^
      petId.hashCode ^
      title.hashCode ^
      doctor.hashCode ^
      scheduledAt.hashCode ^
      notes.hashCode ^
      status.hashCode ^
      appointmentType.hashCode ^
      location.hashCode ^
      cost.hashCode;
}

@immutable
class PetVaccination {
  final String id;
  final String petId;
  final String vaccineName;
  final String status; // scheduled | completed
  final DateTime? scheduledFor;
  final DateTime? completedOn;
  final DateTime? nextDueDate;
  final String? administeredBy;
  final String? batchNumber;
  final String? notes;

  const PetVaccination({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.status,
    this.scheduledFor,
    this.completedOn,
    this.nextDueDate,
    this.administeredBy,
    this.batchNumber,
    this.notes,
  });

  bool get isCompleted => status == 'completed';

  bool get isDueSoon {
    if (nextDueDate == null) return false;
    return nextDueDate!.difference(DateTime.now()).inDays <= 30;
  }

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
      nextDueDate: parseDate(json['next_due_date']),
      administeredBy: json['administered_by'] as String?,
      batchNumber: json['batch_number'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toUpsertJson() => {
    if (id.isNotEmpty) 'id': id,
    'pet_id': petId,
    'vaccine_name': vaccineName,
    'status': status,
    if (scheduledFor != null)
      'scheduled_for': scheduledFor!.toIso8601String().split('T').first,
    if (completedOn != null)
      'completed_on': completedOn!.toIso8601String().split('T').first,
    if (nextDueDate != null)
      'next_due_date': nextDueDate!.toIso8601String().split('T').first,
    if (administeredBy != null) 'administered_by': administeredBy,
    if (batchNumber != null) 'batch_number': batchNumber,
    if (notes != null) 'notes': notes,
  };

  Map<String, dynamic> toJson() => toUpsertJson();

  PetVaccination copyWith({
    String? id,
    String? petId,
    String? vaccineName,
    String? status,
    DateTime? scheduledFor,
    DateTime? completedOn,
    DateTime? nextDueDate,
    String? administeredBy,
    String? batchNumber,
    String? notes,
  }) => PetVaccination(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    vaccineName: vaccineName ?? this.vaccineName,
    status: status ?? this.status,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    completedOn: completedOn ?? this.completedOn,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    administeredBy: administeredBy ?? this.administeredBy,
    batchNumber: batchNumber ?? this.batchNumber,
    notes: notes ?? this.notes,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetVaccination &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          vaccineName == other.vaccineName &&
          status == other.status &&
          scheduledFor == other.scheduledFor &&
          completedOn == other.completedOn &&
          nextDueDate == other.nextDueDate &&
          administeredBy == other.administeredBy &&
          batchNumber == other.batchNumber &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      petId.hashCode ^
      vaccineName.hashCode ^
      status.hashCode ^
      scheduledFor.hashCode ^
      completedOn.hashCode ^
      nextDueDate.hashCode ^
      administeredBy.hashCode ^
      batchNumber.hashCode ^
      notes.hashCode;
}
