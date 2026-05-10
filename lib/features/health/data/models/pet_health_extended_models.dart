import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PetMedication
// ─────────────────────────────────────────────────────────────────────────────
@immutable

class PetMedication { // active | paused | completed

  const PetMedication({
    required this.id,
    required this.petId,
    required this.name,
    this.dose,
    required this.frequency,
    this.timesOfDay = const [],
    required this.startDate,
    this.endDate,
    this.purpose,
    this.notes,
    required this.status,
  });

  factory PetMedication.fromJson(Map<String, dynamic> json) {
    return PetMedication(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      name: json['name'] as String,
      dose: json['dose'] as String?,
      frequency: json['frequency'] as String? ?? 'once_daily',
      timesOfDay:
          (json['times_of_day'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      purpose: json['purpose'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }
  final String id;
  final String petId;
  final String name;
  final String? dose;
  final String frequency;
  final List<String> timesOfDay;
  final DateTime startDate;
  final DateTime? endDate;
  final String? purpose;
  final String? notes;
  final String status;

  bool get isActive => status == 'active';

  String get frequencyLabel {
    switch (frequency) {
      case 'once_daily':
        return 'Once daily';
      case 'twice_daily':
        return 'Twice daily';
      case 'three_times_daily':
        return '3× daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'as_needed':
        return 'As needed';
      default:
        return frequency;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Active';
      case 'paused':
        return 'Paused';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'active':
        return AppTheme.secondaryAccent;
      case 'paused':
        return AppTheme.textSecondary;
      case 'completed':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  Map<String, dynamic> toUpsertJson() => {
    if (id.isNotEmpty) 'id': id,
    'pet_id': petId,
    'name': name,
    if (dose != null) 'dose': dose,
    'frequency': frequency,
    'times_of_day': timesOfDay,
    'start_date': startDate.toIso8601String().split('T').first,
    if (endDate != null)
      'end_date': endDate!.toIso8601String().split('T').first,
    if (purpose != null) 'purpose': purpose,
    if (notes != null) 'notes': notes,
    'status': status,
  };

  Map<String, dynamic> toJson() => toUpsertJson();

  PetMedication copyWith({
    String? id,
    String? petId,
    String? name,
    String? dose,
    String? frequency,
    List<String>? timesOfDay,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    String? purpose,
    String? notes,
    String? status,
  }) => PetMedication(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    name: name ?? this.name,
    dose: dose ?? this.dose,
    frequency: frequency ?? this.frequency,
    timesOfDay: timesOfDay ?? this.timesOfDay,
    startDate: startDate ?? this.startDate,
    endDate: clearEndDate ? null : (endDate ?? this.endDate),
    purpose: purpose ?? this.purpose,
    notes: notes ?? this.notes,
    status: status ?? this.status,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetMedication &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          name == other.name &&
          dose == other.dose &&
          frequency == other.frequency &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id, petId, name, dose, frequency, startDate, endDate, status,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MedicationDose
// ─────────────────────────────────────────────────────────────────────────────
@immutable

class MedicationDose {

  const MedicationDose({
    required this.id,
    required this.medicationId,
    required this.petId,
    required this.scheduledFor,
    this.givenAt,
    required this.skipped,
    this.notes,
  });

  factory MedicationDose.fromJson(Map<String, dynamic> json) {
    return MedicationDose(
      id: json['id'] as String,
      medicationId: json['medication_id'] as String,
      petId: json['pet_id'] as String,
      scheduledFor: DateTime.parse(json['scheduled_for'] as String).toLocal(),
      givenAt: json['given_at'] != null
          ? DateTime.parse(json['given_at'] as String).toLocal()
          : null,
      skipped: json['skipped'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
  final String id;
  final String medicationId;
  final String petId;
  final DateTime scheduledFor;
  final DateTime? givenAt;
  final bool skipped;
  final String? notes;

  bool get isGiven => givenAt != null && !skipped;
  bool get isPending => givenAt == null && !skipped;
  bool get isOverdue => isPending && scheduledFor.isBefore(DateTime.now());

  Color get statusColor {
    if (isGiven) return AppTheme.secondaryAccent;
    if (isOverdue) return AppTheme.alertAccent;
    return AppTheme.textSecondary;
  }

  Map<String, dynamic> toUpsertJson() => {
    if (id.isNotEmpty) 'id': id,
    'medication_id': medicationId,
    'pet_id': petId,
    'scheduled_for': scheduledFor.toUtc().toIso8601String(),
    if (givenAt != null) 'given_at': givenAt!.toUtc().toIso8601String(),
    'skipped': skipped,
    if (notes != null) 'notes': notes,
  };

  Map<String, dynamic> toJson() => toUpsertJson();

  MedicationDose copyWith({
    String? id,
    String? medicationId,
    String? petId,
    DateTime? scheduledFor,
    DateTime? givenAt,
    bool? skipped,
    String? notes,
  }) => MedicationDose(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    petId: petId ?? this.petId,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    givenAt: givenAt ?? this.givenAt,
    skipped: skipped ?? this.skipped,
    notes: notes ?? this.notes,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationDose &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          medicationId == other.medicationId &&
          scheduledFor == other.scheduledFor &&
          givenAt == other.givenAt &&
          skipped == other.skipped;

  @override
  int get hashCode => Object.hash(
    id, medicationId, scheduledFor, givenAt, skipped,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PetAllergy
// ─────────────────────────────────────────────────────────────────────────────
@immutable

class PetAllergy {

  const PetAllergy({
    required this.id,
    required this.petId,
    required this.allergen,
    required this.allergenType,
    required this.severity,
    this.reaction,
    this.diagnosedOn,
    required this.isActive,
    this.notes,
  });

  factory PetAllergy.fromJson(Map<String, dynamic> json) {
    return PetAllergy(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      allergen: json['allergen'] as String,
      allergenType: json['allergen_type'] as String? ?? 'food',
      severity: json['severity'] as String? ?? 'mild',
      reaction: json['reaction'] as String?,
      diagnosedOn: json['diagnosed_on'] != null
          ? DateTime.parse(json['diagnosed_on'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }
  final String id;
  final String petId;
  final String allergen;
  final String allergenType; // food | environmental | drug | insect | other
  final String severity; // mild | moderate | severe | life_threatening
  final String? reaction;
  final DateTime? diagnosedOn;
  final bool isActive;
  final String? notes;

  Color get severityColor {
    switch (severity) {
      case 'life_threatening':
        return const Color(0xFFE85D75); // error
      case 'severe':
        return const Color(0xFFE85D75); // error
      case 'moderate':
        return AppTheme.primaryAccent;
      default:
        return AppTheme.secondaryAccent;
    }
  }

  String get severityLabel {
    switch (severity) {
      case 'life_threatening':
        return 'Life-Threatening';
      case 'severe':
        return 'Severe';
      case 'moderate':
        return 'Moderate';
      default:
        return 'Mild';
    }
  }

  String get allergenTypeLabel {
    switch (allergenType) {
      case 'environmental':
        return 'Environmental';
      case 'drug':
        return 'Drug';
      case 'insect':
        return 'Insect';
      case 'other':
        return 'Other';
      default:
        return 'Food';
    }
  }

  Map<String, dynamic> toInsertJson() => {
    'pet_id': petId,
    'allergen': allergen,
    'allergen_type': allergenType,
    'severity': severity,
    if (reaction != null) 'reaction': reaction,
    if (diagnosedOn != null)
      'diagnosed_on': diagnosedOn!.toIso8601String().split('T').first,
    'is_active': isActive,
    if (notes != null) 'notes': notes,
  };

  Map<String, dynamic> toJson() => toInsertJson();

  PetAllergy copyWith({
    String? id,
    String? petId,
    String? allergen,
    String? allergenType,
    String? severity,
    String? reaction,
    DateTime? diagnosedOn,
    bool? isActive,
    String? notes,
  }) => PetAllergy(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    allergen: allergen ?? this.allergen,
    allergenType: allergenType ?? this.allergenType,
    severity: severity ?? this.severity,
    reaction: reaction ?? this.reaction,
    diagnosedOn: diagnosedOn ?? this.diagnosedOn,
    isActive: isActive ?? this.isActive,
    notes: notes ?? this.notes,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAllergy &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          allergen == other.allergen &&
          allergenType == other.allergenType &&
          severity == other.severity &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(
    id, petId, allergen, allergenType, severity, isActive,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ParasitePrevention
// ─────────────────────────────────────────────────────────────────────────────
@immutable

class ParasitePrevention {

  const ParasitePrevention({
    required this.id,
    required this.petId,
    required this.productName,
    required this.productType,
    required this.administeredOn,
    this.nextDueDate,
    this.notes,
  });

  factory ParasitePrevention.fromJson(Map<String, dynamic> json) {
    return ParasitePrevention(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      productName: json['product_name'] as String,
      productType: json['product_type'] as String,
      administeredOn: DateTime.parse(json['administered_on'] as String),
      nextDueDate: json['next_due_date'] != null
          ? DateTime.parse(json['next_due_date'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
  final String id;
  final String petId;
  final String productName;
  final String productType; // flea|tick|flea_tick|heartworm|dewormer|other
  final DateTime administeredOn;
  final DateTime? nextDueDate;
  final String? notes;

  bool get isOverdue =>
      nextDueDate != null && nextDueDate!.isBefore(DateTime.now());

  int? get daysUntilDue {
    if (nextDueDate == null) return null;
    return nextDueDate!.difference(DateTime.now()).inDays;
  }

  Color get urgencyColor {
    if (isOverdue) return const Color(0xFFE85D75); // error
    final days = daysUntilDue;
    if (days != null && days <= 7) return AppTheme.primaryAccent;
    return AppTheme.secondaryAccent;
  }

  String get productTypeLabel {
    switch (productType) {
      case 'flea':
        return 'Flea';
      case 'tick':
        return 'Tick';
      case 'flea_tick':
        return 'Flea & Tick';
      case 'heartworm':
        return 'Heartworm';
      case 'dewormer':
        return 'Dewormer';
      default:
        return 'Other';
    }
  }

  Map<String, dynamic> toInsertJson() => {
    'pet_id': petId,
    'product_name': productName,
    'product_type': productType,
    'administered_on': administeredOn.toIso8601String().split('T').first,
    if (nextDueDate != null)
      'next_due_date': nextDueDate!.toIso8601String().split('T').first,
    if (notes != null) 'notes': notes,
  };

  Map<String, dynamic> toJson() => toInsertJson();

  ParasitePrevention copyWith({
    String? id,
    String? petId,
    String? productName,
    String? productType,
    DateTime? administeredOn,
    DateTime? nextDueDate,
    bool clearNextDue = false,
    String? notes,
  }) => ParasitePrevention(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    productName: productName ?? this.productName,
    productType: productType ?? this.productType,
    administeredOn: administeredOn ?? this.administeredOn,
    nextDueDate: clearNextDue ? null : (nextDueDate ?? this.nextDueDate),
    notes: notes ?? this.notes,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParasitePrevention &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          productName == other.productName &&
          productType == other.productType &&
          administeredOn == other.administeredOn &&
          nextDueDate == other.nextDueDate;

  @override
  int get hashCode => Object.hash(
    id, petId, productName, productType, administeredOn, nextDueDate,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DentalLog
// ─────────────────────────────────────────────────────────────────────────────
@immutable

class DentalLog {

  const DentalLog({
    required this.id,
    required this.petId,
    required this.logDate,
    required this.cleaningType,
    this.notes,
  });

  factory DentalLog.fromJson(Map<String, dynamic> json) {
    return DentalLog(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      cleaningType: json['cleaning_type'] as String,
      notes: json['notes'] as String?,
    );
  }
  final String id;
  final String petId;
  final DateTime logDate;
  final String
  cleaningType; // home_brushing|dental_chew|professional_cleaning|water_additive
  final String? notes;

  String get cleaningTypeLabel {
    switch (cleaningType) {
      case 'home_brushing':
        return 'Home Brushing';
      case 'dental_chew':
        return 'Dental Chew';
      case 'professional_cleaning':
        return 'Professional Cleaning';
      case 'water_additive':
        return 'Water Additive';
      default:
        return cleaningType;
    }
  }

  IconData get cleaningIcon {
    switch (cleaningType) {
      case 'professional_cleaning':
        return Icons.medical_services;
      case 'dental_chew':
        return Icons.cookie;
      case 'water_additive':
        return Icons.water_drop;
      default:
        return Icons.brush;
    }
  }

  Map<String, dynamic> toInsertJson() => {
    'pet_id': petId,
    'log_date': logDate.toIso8601String().split('T').first,
    'cleaning_type': cleaningType,
    if (notes != null) 'notes': notes,
  };

  Map<String, dynamic> toJson() => toInsertJson();

  DentalLog copyWith({
    String? id,
    String? petId,
    DateTime? logDate,
    String? cleaningType,
    String? notes,
  }) => DentalLog(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    logDate: logDate ?? this.logDate,
    cleaningType: cleaningType ?? this.cleaningType,
    notes: notes ?? this.notes,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DentalLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          logDate == other.logDate &&
          cleaningType == other.cleaningType;

  @override
  int get hashCode => Object.hash(id, petId, logDate, cleaningType);
}
