import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/health/data/models/pet_health_extended_models.dart';
import 'package:petfolio/features/health/data/health_repository.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/core/constants/app_strings.dart';
import 'package:petfolio/core/utils/logger.dart';

@immutable
class MedicationState {

  const MedicationState({
    this.medications = const [],
    this.todayDoses = const [],
    this.isLoading = false,
    this.error,
    this.activePetId,
  });
  final List<PetMedication> medications;
  final List<MedicationDose> todayDoses;
  final bool isLoading;
  final String? error;
  final String? activePetId;

  List<PetMedication> get activeMedications =>
      medications.where((m) => m.isActive).toList();

  List<PetMedication> get inactiveMedications =>
      medications.where((m) => !m.isActive).toList();

  MedicationDose? todayDoseFor(String medicationId) {
    try {
      return todayDoses.firstWhere((d) => d.medicationId == medicationId);
    } catch (_) {
      return null;
    }
  }

  MedicationState copyWith({
    List<PetMedication>? medications,
    List<MedicationDose>? todayDoses,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? activePetId,
  }) => MedicationState(
    medications: medications ?? this.medications,
    todayDoses: todayDoses ?? this.todayDoses,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    activePetId: activePetId ?? this.activePetId,
  );
}

class MedicationNotifier extends Notifier<MedicationState> {
  HealthRepository get _repo => ref.read(healthRepositoryProvider);

  @override
  MedicationState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return MedicationState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      activePetId: petId,
    );
    try {
      final results = await Future.wait([
        _repo.fetchMedications(petId),
        _repo.fetchTodayDoses(petId),
      ]);
      if (!ref.mounted) return;
      state = state.copyWith(
        medications: results[0] as List<PetMedication>,
        todayDoses: results[1] as List<MedicationDose>,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      AppLogger.error(
        AppStrings.healthLoadFailed,
        tag: 'MedicationNotifier',
        error: e,
      );
      state = state.copyWith(isLoading: false, error: AppStrings.healthLoadFailed);
    }
  }

  Future<void> refresh() async {
    final id = state.activePetId ?? ref.read(activePetProvider)?.id;
    if (id != null) await _load(id);
  }

  Future<void> addMedication(PetMedication med) async {
    try {
      final saved = await _repo.upsertMedication(med);
      state = state.copyWith(medications: [saved, ...state.medications]);
      await _generateUpcomingDoses(saved);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthMedicationAddFailed,
        tag: 'MedicationNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthMedicationAddFailed);
    }
  }

  Future<void> updateMedication(PetMedication med) async {
    try {
      final saved = await _repo.upsertMedication(med);
      state = state.copyWith(
        medications: state.medications
            .map((m) => m.id == saved.id ? saved : m)
            .toList(),
      );
      await _generateUpcomingDoses(saved);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthMedicationUpdateFailed,
        tag: 'MedicationNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthMedicationUpdateFailed);
    }
  }

  Future<void> deleteMedication(String id) async {
    state = state.copyWith(
      medications: state.medications.where((m) => m.id != id).toList(),
    );
    try {
      await _repo.deleteMedication(id);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthMedicationDeleteFailed,
        tag: 'MedicationNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthMedicationDeleteFailed);
      await refresh();
    }
  }

  Future<void> markDoseGiven(MedicationDose dose) async {
    try {
      final saved = await _repo.markDoseGiven(dose);
      _updateDose(saved);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthDoseMarkGivenFailed,
        tag: 'MedicationNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthDoseMarkGivenFailed);
    }
  }

  Future<void> skipDose(MedicationDose dose) async {
    try {
      final saved = await _repo.skipDose(dose);
      _updateDose(saved);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthDoseSkipFailed,
        tag: 'MedicationNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthDoseSkipFailed);
    }
  }

  void _updateDose(MedicationDose updated) {
    final existing = state.todayDoses.any((d) => d.id == updated.id);
    state = state.copyWith(
      todayDoses: existing
          ? state.todayDoses
                .map((d) => d.id == updated.id ? updated : d)
                .toList()
          : [updated, ...state.todayDoses],
    );
  }

  Future<void> _generateUpcomingDoses(PetMedication med) async {
    if (!med.isActive) return;
    if (med.frequency == 'as_needed') return;

    final now = DateTime.now();
    final end = now.add(const Duration(days: 30));
    final doses = <MedicationDose>[];

    var cursor = med.startDate.isAfter(now) ? med.startDate : now;
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    while (cursor.isBefore(end)) {
      if (med.endDate != null && cursor.isAfter(med.endDate!)) break;

      final timesForDay = _timesForFrequency(med);
      for (final hour in timesForDay) {
        final scheduled = cursor.add(Duration(hours: hour));
        if (scheduled.isBefore(now.subtract(const Duration(hours: 1)))) {
          continue;
        }
        doses.add(
          MedicationDose(
            id: '',
            medicationId: med.id,
            petId: med.petId,
            scheduledFor: scheduled,
            skipped: false,
          ),
        );
      }
      cursor = _nextCursor(med.frequency, cursor);
    }

    if (doses.isEmpty) return;
    try {
      await _repo.generateDosesIdempotent(doses);
      if (!ref.mounted) return;
      final today = await _repo.fetchTodayDoses(med.petId);
      state = state.copyWith(todayDoses: today);
    } catch (e) {
      log('Dose generation failed: $e', name: 'MedicationNotifier');
    }
  }

  List<int> _timesForFrequency(PetMedication med) {
    if (med.timesOfDay.isNotEmpty) {
      return med.timesOfDay.map((t) {
        switch (t) {
          case 'morning':
            return 8;
          case 'noon':
            return 12;
          case 'evening':
            return 18;
          case 'night':
            return 21;
          default:
            return 8;
        }
      }).toList();
    }
    switch (med.frequency) {
      case 'twice_daily':
        return [8, 20];
      case 'three_times_daily':
        return [8, 14, 20];
      default:
        return [8];
    }
  }

  DateTime _nextCursor(String frequency, DateTime from) {
    switch (frequency) {
      case 'weekly':
        return from.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(from.year, from.month + 1, from.day);
      default:
        return from.add(const Duration(days: 1));
    }
  }
}

final medicationProvider =
    NotifierProvider<MedicationNotifier, MedicationState>(
      MedicationNotifier.new,
    );
