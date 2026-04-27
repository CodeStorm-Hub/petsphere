import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_health_extended_models.dart';
import '../models/pet_health_models.dart';
import '../repositories/health_repository.dart';
import 'pet_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class HealthState {
  final List<PetMedication>     medications;
  final List<MedicationDose>    todayDoses;
  final List<PetAllergy>        allergies;
  final List<ParasitePrevention>parasitePrevention;
  final List<DentalLog>         dentalLogs;
  final bool isLoading;
  final String? error;
  final String? activePetId;

  const HealthState({
    this.medications        = const [],
    this.todayDoses         = const [],
    this.allergies          = const [],
    this.parasitePrevention = const [],
    this.dentalLogs         = const [],
    this.isLoading = false,
    this.error,
    this.activePetId,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  List<PetMedication> get activeMedications =>
      medications.where((m) => m.isActive).toList();

  List<PetMedication> get inactiveMedications =>
      medications.where((m) => !m.isActive).toList();

  List<ParasitePrevention> get overdueParasite =>
      parasitePrevention.where((p) => p.isOverdue).toList();

  List<ParasitePrevention> get latestPerType {
    final seen = <String>{};
    final result = <ParasitePrevention>[];
    for (final p in parasitePrevention) {
      if (!seen.contains(p.productType)) {
        seen.add(p.productType);
        result.add(p);
      }
    }
    return result;
  }

  DentalLog? get lastHomeBrushing => dentalLogs.firstWhere(
        (d) => d.cleaningType == 'home_brushing',
        orElse: () => DentalLog(
          id: '', petId: '', logDate: DateTime(2000),
          cleaningType: 'home_brushing',
        ),
      );

  DentalLog? get lastProfessionalCleaning => dentalLogs.firstWhere(
        (d) => d.cleaningType == 'professional_cleaning',
        orElse: () => DentalLog(
          id: '', petId: '', logDate: DateTime(2000),
          cleaningType: 'professional_cleaning',
        ),
      );

  /// Number of active health alerts (overdue medications, parasite, etc.)
  int get alertCount {
    int count = 0;
    count += overdueParasite.length;
    count += todayDoses.where((d) => d.isOverdue).length;
    return count;
  }

  /// Dose object for a given medication id, or null if not found today.
  MedicationDose? todayDoseFor(String medicationId) {
    try {
      return todayDoses.firstWhere((d) => d.medicationId == medicationId);
    } catch (_) {
      return null;
    }
  }

  HealthState copyWith({
    List<PetMedication>?      medications,
    List<MedicationDose>?     todayDoses,
    List<PetAllergy>?         allergies,
    List<ParasitePrevention>? parasitePrevention,
    List<DentalLog>?          dentalLogs,
    bool?    isLoading,
    String?  error,
    String?  activePetId,
  }) =>
      HealthState(
        medications:        medications        ?? this.medications,
        todayDoses:         todayDoses         ?? this.todayDoses,
        allergies:          allergies          ?? this.allergies,
        parasitePrevention: parasitePrevention ?? this.parasitePrevention,
        dentalLogs:         dentalLogs         ?? this.dentalLogs,
        isLoading:          isLoading          ?? this.isLoading,
        error:              error,
        activePetId:        activePetId        ?? this.activePetId,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class HealthNotifier extends Notifier<HealthState> {
  final _repo = healthRepository;

  @override
  HealthState build() {
    ref.listen<String?>(
      activePetProvider.select((p) => p?.id),
      (prev, next) {
        if (next != null && next != prev) _loadAll(next);
      },
    );
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _loadAll(petId));
    }
    return HealthState(isLoading: petId != null);
  }

  Future<void> _loadAll(String petId) async {
    state = state.copyWith(isLoading: true, error: null, activePetId: petId);
    try {
      final results = await Future.wait([
        _repo.fetchMedications(petId),
        _repo.fetchTodayDoses(petId),
        _repo.fetchAllergies(petId),
        _repo.fetchParasitePrevention(petId),
        _repo.fetchDentalLogs(petId),
      ]);
      if (!ref.mounted) return;
      state = state.copyWith(
        medications:        results[0] as List<PetMedication>,
        todayDoses:         results[1] as List<MedicationDose>,
        allergies:          results[2] as List<PetAllergy>,
        parasitePrevention: results[3] as List<ParasitePrevention>,
        dentalLogs:         results[4] as List<DentalLog>,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final id = state.activePetId;
    if (id != null) await _loadAll(id);
  }

  // ── Medication mutations ─────────────────────────────────────────────────

  Future<void> addMedication(PetMedication med) async {
    try {
      final saved = await _repo.upsertMedication(med);
      state = state.copyWith(
        medications: [saved, ...state.medications],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateMedication(PetMedication med) async {
    try {
      final saved = await _repo.upsertMedication(med);
      state = state.copyWith(
        medications: state.medications.map((m) => m.id == saved.id ? saved : m).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteMedication(String id) async {
    state = state.copyWith(
      medications: state.medications.where((m) => m.id != id).toList(),
    );
    try {
      await _repo.deleteMedication(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      await refresh();
    }
  }

  // ── Dose mutations ───────────────────────────────────────────────────────

  Future<void> markDoseGiven(MedicationDose dose) async {
    try {
      final saved = await _repo.markDoseGiven(dose);
      _updateDose(saved);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> skipDose(MedicationDose dose) async {
    try {
      final saved = await _repo.skipDose(dose);
      _updateDose(saved);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _updateDose(MedicationDose updated) {
    final existing = state.todayDoses.any((d) => d.id == updated.id);
    state = state.copyWith(
      todayDoses: existing
          ? state.todayDoses.map((d) => d.id == updated.id ? updated : d).toList()
          : [updated, ...state.todayDoses],
    );
  }

  // ── Allergy mutations ────────────────────────────────────────────────────

  Future<void> addAllergy(PetAllergy allergy) async {
    try {
      final saved = await _repo.insertAllergy(allergy);
      state = state.copyWith(allergies: [saved, ...state.allergies]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeAllergy(String id) async {
    state = state.copyWith(
      allergies: state.allergies.where((a) => a.id != id).toList(),
    );
    try {
      await _repo.deleteAllergy(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      await refresh();
    }
  }

  // ── Parasite prevention mutations ────────────────────────────────────────

  Future<void> logParasiteTreatment(ParasitePrevention entry) async {
    try {
      final saved = await _repo.logParasiteTreatment(entry);
      state = state.copyWith(
        parasitePrevention: [saved, ...state.parasitePrevention],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteParasiteEntry(String id) async {
    state = state.copyWith(
      parasitePrevention:
          state.parasitePrevention.where((p) => p.id != id).toList(),
    );
    try {
      await _repo.deleteParasiteEntry(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      await refresh();
    }
  }

  // ── Dental mutations ─────────────────────────────────────────────────────

  Future<void> logDental(DentalLog entry) async {
    try {
      final saved = await _repo.logDental(entry);
      state = state.copyWith(dentalLogs: [saved, ...state.dentalLogs]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteDentalLog(String id) async {
    state = state.copyWith(
      dentalLogs: state.dentalLogs.where((d) => d.id != id).toList(),
    );
    try {
      await _repo.deleteDentalLog(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      await refresh();
    }
  }

  // ── Vet Appointment mutations ─────────────────────────────────────────────

  Future<void> upsertAppointment(PetVetAppointment appt) async {
    try {
      await _repo.upsertAppointment(appt);
      // Refresh care state (appointments are owned by petCareProvider)
      // This triggers a reload of appointments in PetCareNotifier.
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      await _repo.cancelAppointment(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── Vaccination mutations ────────────────────────────────────────────────

  Future<void> upsertVaccination(PetVaccination vax) async {
    try {
      await _repo.upsertVaccination(vax);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markVaccinationComplete(String id) async {
    try {
      await _repo.markVaccinationComplete(id, DateTime.now());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final healthProvider = NotifierProvider<HealthNotifier, HealthState>(
  HealthNotifier.new,
);
