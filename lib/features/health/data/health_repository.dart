import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/pet_health_extended_models.dart';
import '../data/models/pet_health_models.dart';
import 'package:petfolio/core/constants/supabase_config.dart';

/// Repository for all extended health data:
/// medications, doses, allergies, parasite prevention, dental logs.
/// Vet appointments & vaccinations remain in [PetCareRepository].
class HealthRepository {
  final _db = supabase;

  // ──────────────────────────────────────────────────────────────────────────
  // Medications
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<PetMedication>> fetchMedications(String petId) async {
    final rows = await _db
        .from('pet_medications')
        .select()
        .eq('pet_id', petId)
        .order('created_at', ascending: false);
    return rows.map((r) => PetMedication.fromJson(r)).toList();
  }

  Future<PetMedication> upsertMedication(PetMedication med) async {
    final row = await _db
        .from('pet_medications')
        .upsert(med.toUpsertJson(), onConflict: 'id')
        .select()
        .single();
    return PetMedication.fromJson(row);
  }

  Future<void> deleteMedication(String id) async {
    await _db.from('pet_medications').delete().eq('id', id);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Medication Doses
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetch doses for a given medication on [date].
  Future<List<MedicationDose>> fetchDosesForDate(
    String medicationId,
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day).toUtc();
    final end = start.add(const Duration(days: 1));
    final rows = await _db
        .from('pet_medication_doses')
        .select()
        .eq('medication_id', medicationId)
        .gte('scheduled_for', start.toIso8601String())
        .lt('scheduled_for', end.toIso8601String())
        .order('scheduled_for');
    return rows.map((r) => MedicationDose.fromJson(r)).toList();
  }

  /// Fetch all doses for a pet on today.
  Future<List<MedicationDose>> fetchTodayDoses(String petId) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toUtc();
    final end = start.add(const Duration(days: 1));
    final rows = await _db
        .from('pet_medication_doses')
        .select()
        .eq('pet_id', petId)
        .gte('scheduled_for', start.toIso8601String())
        .lt('scheduled_for', end.toIso8601String())
        .order('scheduled_for');
    return rows.map((r) => MedicationDose.fromJson(r)).toList();
  }

  Future<MedicationDose> logDose(MedicationDose dose) async {
    final row = await _db
        .from('pet_medication_doses')
        .upsert(dose.toUpsertJson(), onConflict: 'id')
        .select()
        .single();
    return MedicationDose.fromJson(row);
  }

  /// Mark a dose as given now. Creates or updates the dose row.
  Future<MedicationDose> markDoseGiven(MedicationDose dose) async {
    final updated = MedicationDose(
      id: dose.id,
      medicationId: dose.medicationId,
      petId: dose.petId,
      scheduledFor: dose.scheduledFor,
      givenAt: DateTime.now(),
      skipped: false,
      notes: dose.notes,
    );
    return logDose(updated);
  }

  /// Mark a dose as skipped.
  Future<MedicationDose> skipDose(MedicationDose dose) async {
    final updated = MedicationDose(
      id: dose.id,
      medicationId: dose.medicationId,
      petId: dose.petId,
      scheduledFor: dose.scheduledFor,
      skipped: true,
      notes: dose.notes,
    );
    return logDose(updated);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Allergies
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<PetAllergy>> fetchAllergies(String petId) async {
    final rows = await _db
        .from('pet_allergies')
        .select()
        .eq('pet_id', petId)
        .order('created_at', ascending: false);
    return rows.map((r) => PetAllergy.fromJson(r)).toList();
  }

  Future<PetAllergy> insertAllergy(PetAllergy allergy) async {
    final row = await _db
        .from('pet_allergies')
        .insert(allergy.toInsertJson())
        .select()
        .single();
    return PetAllergy.fromJson(row);
  }

  Future<void> deactivateAllergy(String id) async {
    await _db.from('pet_allergies').update({'is_active': false}).eq('id', id);
  }

  Future<void> deleteAllergy(String id) async {
    await _db.from('pet_allergies').delete().eq('id', id);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Parasite Prevention
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<ParasitePrevention>> fetchParasitePrevention(String petId) async {
    final rows = await _db
        .from('pet_parasite_prevention')
        .select()
        .eq('pet_id', petId)
        .order('administered_on', ascending: false);
    return rows.map((r) => ParasitePrevention.fromJson(r)).toList();
  }

  Future<ParasitePrevention> logParasiteTreatment(
    ParasitePrevention entry,
  ) async {
    final row = await _db
        .from('pet_parasite_prevention')
        .insert(entry.toInsertJson())
        .select()
        .single();
    return ParasitePrevention.fromJson(row);
  }

  Future<void> deleteParasiteEntry(String id) async {
    await _db.from('pet_parasite_prevention').delete().eq('id', id);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dental Logs
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<DentalLog>> fetchDentalLogs(
    String petId, {
    int limit = 20,
  }) async {
    final rows = await _db
        .from('pet_dental_logs')
        .select()
        .eq('pet_id', petId)
        .order('log_date', ascending: false)
        .limit(limit);
    return rows.map((r) => DentalLog.fromJson(r)).toList();
  }

  Future<DentalLog> logDental(DentalLog entry) async {
    final row = await _db
        .from('pet_dental_logs')
        .insert(entry.toInsertJson())
        .select()
        .single();
    return DentalLog.fromJson(row);
  }

  Future<void> deleteDentalLog(String id) async {
    await _db.from('pet_dental_logs').delete().eq('id', id);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Vet Appointments (CRUD, extended from PetCareRepository read-only methods)
  // ──────────────────────────────────────────────────────────────────────────

  Future<PetVetAppointment> upsertAppointment(PetVetAppointment appt) async {
    final row = await _db
        .from('pet_vet_appointments')
        .upsert(appt.toUpsertJson(), onConflict: 'id')
        .select()
        .single();
    return PetVetAppointment.fromJson(row);
  }

  Future<void> cancelAppointment(String id) async {
    await _db
        .from('pet_vet_appointments')
        .update({'status': 'cancelled'})
        .eq('id', id);
  }

  Future<void> deleteAppointment(String id) async {
    await _db.from('pet_vet_appointments').delete().eq('id', id);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Vaccinations (CRUD extension)
  // ──────────────────────────────────────────────────────────────────────────

  Future<PetVaccination> upsertVaccination(PetVaccination vax) async {
    final row = await _db
        .from('pet_vaccinations')
        .upsert(vax.toUpsertJson(), onConflict: 'id')
        .select()
        .single();
    return PetVaccination.fromJson(row);
  }

  Future<PetVaccination> markVaccinationComplete(
    String id,
    DateTime completedOn,
  ) async {
    final existingRow = await _db
        .from('pet_vaccinations')
        .select('vaccine_name')
        .eq('id', id)
        .single();

    final vaccineName = existingRow['vaccine_name'] as String;

    final scheduleRow = await _db
        .from('vaccination_schedules')
        .select('interval_months')
        .eq('vaccine_name', vaccineName)
        .maybeSingle();

    String? nextDueDateStr;
    if (scheduleRow != null) {
      final months = scheduleRow['interval_months'] as int;
      final nextDate = DateTime(
        completedOn.year,
        completedOn.month + months,
        completedOn.day,
      );
      nextDueDateStr = nextDate.toIso8601String().split('T').first;
    }

    final updateData = <String, dynamic>{
      'status': 'completed',
      'completed_on': completedOn.toIso8601String().split('T').first,
    };
    if (nextDueDateStr != null) {
      updateData['next_due_date'] = nextDueDateStr;
    }

    final row = await _db
        .from('pet_vaccinations')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();
    return PetVaccination.fromJson(row);
  }

  Future<void> deleteVaccination(String id) async {
    await _db.from('pet_vaccinations').delete().eq('id', id);
  }

  Future<List<PetVetAppointment>> fetchUpcomingAppointments(
    String petId,
  ) async {
    final now = DateTime.now();
    final rows = await _db
        .from('pet_vet_appointments')
        .select()
        .eq('pet_id', petId)
        .gte('scheduled_at', now.toIso8601String())
        .order('scheduled_at');
    return rows.map((r) => PetVetAppointment.fromJson(r)).toList();
  }

  Future<void> generateDosesIdempotent(List<MedicationDose> doses) async {
    if (doses.isEmpty) return;
    const chunkSize = 500;
    for (var i = 0; i < doses.length; i += chunkSize) {
      final chunk = doses.sublist(
        i,
        i + chunkSize > doses.length ? doses.length : i + chunkSize,
      );
      try {
        await _db
            .from('pet_medication_doses')
            .upsert(
              chunk.map((d) => d.toUpsertJson()..remove('id')).toList(),
              onConflict: 'medication_id,scheduled_for',
              ignoreDuplicates: true,
            );
      } catch (e) {
        log(
          'generateDosesIdempotent chunk error: $e',
          name: 'HealthRepository',
        );
      }
    }
  }
}

final healthRepository = HealthRepository();

final healthRepositoryProvider = Provider<HealthRepository>((ref) => healthRepository);
