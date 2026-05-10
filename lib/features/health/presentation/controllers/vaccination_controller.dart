import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petsphere/core/constants/app_strings.dart';
import 'package:petsphere/core/utils/logger.dart';
import 'package:petsphere/features/care/data/pet_care_repository.dart';
import 'package:petsphere/features/health/data/models/pet_health_models.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class VaccinationState {
  final List<PetVaccination> vaccinations;
  final bool isLoading;
  final String? error;

  const VaccinationState({
    this.vaccinations = const [],
    this.isLoading = false,
    this.error,
  });

  List<PetVaccination> get completed =>
      vaccinations.where((v) => v.isCompleted).toList();

  List<PetVaccination> get upcoming =>
      vaccinations.where((v) => !v.isCompleted).toList();

  List<PetVaccination> get dueSoon =>
      vaccinations.where((v) => v.isDueSoon && !v.isCompleted).toList();

  VaccinationState copyWith({
    List<PetVaccination>? vaccinations,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => VaccinationState(
    vaccinations: vaccinations ?? this.vaccinations,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class VaccinationNotifier extends Notifier<VaccinationState> {
  PetCareRepository get _repo => ref.read(petCareRepositoryProvider);


  @override
  VaccinationState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return VaccinationState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final vax = await _repo.fetchVaccinations(petId);
      if (!ref.mounted) return;
      state = state.copyWith(vaccinations: vax, isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.healthLoadFailed,
      );
    }
  }

  Future<void> refresh() async {
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) await _load(petId);
  }

  Future<void> upsertVaccination(PetVaccination vax) async {
    try {
      final saved = await _repo.upsertVaccination(vax);
      state = state.copyWith(
        vaccinations: [
          ...state.vaccinations.where((v) => v.id != saved.id),
          saved,
        ],
      );
    } catch (e) {
      AppLogger.error(
        AppStrings.healthVaccinationFailed,
        tag: 'VaccinationNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthVaccinationFailed);
    }
  }

  Future<void> markComplete(String id) async {
    try {
      final updated = await _repo.markVaccinationComplete(id);
      state = state.copyWith(
        vaccinations: [
          ...state.vaccinations.where((v) => v.id != updated.id),
          updated,
        ],
      );
    } catch (e) {
      AppLogger.error(
        AppStrings.healthVaccinationMarkCompleteFailed,
        tag: 'VaccinationNotifier',
        error: e,
      );
      state = state.copyWith(
        error: AppStrings.healthVaccinationMarkCompleteFailed,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final vaccinationProvider =
    NotifierProvider<VaccinationNotifier, VaccinationState>(
      VaccinationNotifier.new,
    );
