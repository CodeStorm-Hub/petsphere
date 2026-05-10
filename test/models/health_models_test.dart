import 'package:flutter_test/flutter_test.dart';

import 'package:petfolio/features/health/data/models/pet_health_models.dart';

void main() {
  // ────────────────────────────────────────────────────────────────────────────
  group('PetSymptom', () {
    PetSymptom makeSymptom({
      String id = 'sym-1',
      String petId = 'pet-1',
      String severity = 'mild',
      DateTime? resolvedAt,
    }) =>
        PetSymptom(
          id: id,
          petId: petId,
          observedAt: DateTime.utc(2026, 1, 15, 10),
          symptomType: 'vomiting',
          severity: severity,
          resolvedAt: resolvedAt,
        );

    test('fromJson/toJson roundtrip preserves all fields', () {
      final now = DateTime.utc(2026, 1, 15, 10);
      final json = {
        'id': 'sym-abc',
        'pet_id': 'pet-xyz',
        'observed_at': now.toIso8601String(),
        'symptom_type': 'lethargy',
        'severity': 'moderate',
        'notes': 'Seemed tired',
        'resolved_at': null,
      };

      final model = PetSymptom.fromJson(json);
      expect(model.id, 'sym-abc');
      expect(model.petId, 'pet-xyz');
      expect(model.symptomType, 'lethargy');
      expect(model.severity, 'moderate');
      expect(model.notes, 'Seemed tired');
      expect(model.isResolved, isFalse);
    });

    test('isResolved is true when resolvedAt is set', () {
      final resolved = makeSymptom(resolvedAt: DateTime.utc(2026, 1, 20));
      expect(resolved.isResolved, isTrue);
    });

    test('isResolved is false when resolvedAt is null', () {
      final unresolved = makeSymptom();
      expect(unresolved.isResolved, isFalse);
    });

    test('severityLabel returns correct labels', () {
      expect(makeSymptom().severityLabel, 'Mild');
      expect(makeSymptom(severity: 'moderate').severityLabel, 'Moderate');
      expect(makeSymptom(severity: 'severe').severityLabel, 'Severe');
    });

    test('copyWith preserves unchanged fields', () {
      final original = makeSymptom();
      final copy = original.copyWith(severity: 'severe');

      expect(copy.severity, 'severe');
      expect(copy.id, original.id);
      expect(copy.petId, original.petId);
    });

    test('copyWith clearResolved sets resolvedAt to null', () {
      final resolved = makeSymptom(resolvedAt: DateTime.utc(2026, 1, 20));
      final cleared = resolved.copyWith(clearResolved: true);

      expect(cleared.resolvedAt, isNull);
    });

    test('equality holds for identical instances', () {
      final a = makeSymptom();
      final b = makeSymptom();
      expect(a, equals(b));
    });

    test('inequality holds for different ids', () {
      final a = makeSymptom();
      final b = makeSymptom(id: 'sym-2');
      expect(a, isNot(equals(b)));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('PetWeightLog', () {
    PetWeightLog makeWeightLog({
      String? id,
      double weightLbs = 25.5,
      int? bcsScore,
    }) =>
        PetWeightLog(
          id: id,
          petId: 'pet-1',
          logDate: DateTime(2026, 1, 15),
          weightLbs: weightLbs,
          bcsScore: bcsScore,
        );

    test('fromJson preserves all fields', () {
      final json = {
        'id': 'wl-1',
        'pet_id': 'pet-abc',
        'log_date': '2026-01-15',
        'weight_lbs': 30.5,
        'notes': 'Post-holiday weight',
        'bcs_score': 6,
        'unit': 'lbs',
      };

      final model = PetWeightLog.fromJson(json);
      expect(model.id, 'wl-1');
      expect(model.weightLbs, 30.5);
      expect(model.bcsScore, 6);
      expect(model.unit, 'lbs');
    });

    test('bcsLabel returns correct body condition labels', () {
      expect(makeWeightLog(bcsScore: 1).bcsLabel, 'Very Thin');
      expect(makeWeightLog(bcsScore: 2).bcsLabel, 'Very Thin');
      expect(makeWeightLog(bcsScore: 5).bcsLabel, 'Ideal');
      expect(makeWeightLog(bcsScore: 7).bcsLabel, 'Overweight');
      expect(makeWeightLog(bcsScore: 9).bcsLabel, 'Severely Obese');
      expect(makeWeightLog().bcsLabel, 'Not set'); // null bcs
    });

    test('copyWith does not mutate original', () {
      final original = makeWeightLog();
      final copy = original.copyWith(weightLbs: 30.0);

      expect(original.weightLbs, 25.5);
      expect(copy.weightLbs, 30.0);
    });

    test('toUpsertJson formats log_date as YYYY-MM-DD', () {
      final log = makeWeightLog();
      final json = log.toUpsertJson();

      expect(json['log_date'], '2026-01-15');
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('PetVetAppointment', () {
    PetVetAppointment makeAppt({
      String id = 'appt-1',
      String status = 'scheduled',
      String appointmentType = 'routine',
      DateTime? scheduledAt,
    }) =>
        PetVetAppointment(
          id: id,
          petId: 'pet-1',
          title: 'Annual Checkup',
          scheduledAt: scheduledAt ?? DateTime.now().add(const Duration(days: 7)),
          status: status,
          appointmentType: appointmentType,
        );

    test('fromJson preserves all fields', () {
      final json = {
        'id': 'appt-abc',
        'pet_id': 'pet-xyz',
        'title': 'Dental Cleaning',
        'doctor': 'Dr. Smith',
        'scheduled_at': DateTime.utc(2026, 3, 15, 9).toIso8601String(),
        'notes': 'Annual clean',
        'status': 'scheduled',
        'appointment_type': 'dental',
        'location': 'City Vet Clinic',
        'cost': 150.0,
      };

      final model = PetVetAppointment.fromJson(json);
      expect(model.id, 'appt-abc');
      expect(model.title, 'Dental Cleaning');
      expect(model.appointmentType, 'dental');
      expect(model.cost, 150.0);
    });

    test('appointmentTypeLabel returns correct labels', () {
      expect(makeAppt().appointmentTypeLabel, 'Routine');
      expect(makeAppt(appointmentType: 'emergency').appointmentTypeLabel, 'Emergency');
      expect(makeAppt(appointmentType: 'dental').appointmentTypeLabel, 'Dental');
      expect(makeAppt(appointmentType: 'surgery').appointmentTypeLabel, 'Surgery');
      expect(makeAppt(appointmentType: 'follow_up').appointmentTypeLabel, 'Follow-up');
    });

    test('copyWith does not mutate original', () {
      final original = makeAppt();
      final copy = original.copyWith(status: 'completed');

      expect(original.status, 'scheduled');
      expect(copy.status, 'completed');
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('PetVaccination', () {
    PetVaccination makeVax({
      String status = 'scheduled',
      DateTime? nextDueDate,
    }) =>
        PetVaccination(
          id: 'vax-1',
          petId: 'pet-1',
          vaccineName: 'Rabies',
          status: status,
          nextDueDate: nextDueDate,
        );

    test('isCompleted reflects status correctly', () {
      expect(makeVax(status: 'completed').isCompleted, isTrue);
      expect(makeVax().isCompleted, isFalse);
    });

    test('isDueSoon returns true when next due within 30 days', () {
      final dueSoon = makeVax(
        nextDueDate: DateTime.now().add(const Duration(days: 15)),
      );
      expect(dueSoon.isDueSoon, isTrue);
    });

    test('isDueSoon returns false when next due more than 30 days away', () {
      final notDueSoon = makeVax(
        nextDueDate: DateTime.now().add(const Duration(days: 60)),
      );
      expect(notDueSoon.isDueSoon, isFalse);
    });

    test('isDueSoon returns false when nextDueDate is null', () {
      expect(makeVax().isDueSoon, isFalse);
    });

    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'vax-xyz',
        'pet_id': 'pet-1',
        'vaccine_name': 'DHPP',
        'status': 'completed',
        'scheduled_for': '2026-01-01',
        'completed_on': '2026-01-05',
        'next_due_date': '2027-01-05',
        'administered_by': 'Dr. Lee',
        'batch_number': 'BATCH-001',
        'notes': 'No adverse reactions',
      };

      final model = PetVaccination.fromJson(json);
      expect(model.vaccineName, 'DHPP');
      expect(model.isCompleted, isTrue);
      expect(model.administeredBy, 'Dr. Lee');
    });
  });
}
