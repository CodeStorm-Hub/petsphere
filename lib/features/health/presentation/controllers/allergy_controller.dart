import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petsphere/core/constants/app_strings.dart';
import 'package:petsphere/core/utils/logger.dart';
import 'package:petsphere/features/health/data/health_repository.dart';
import 'package:petsphere/features/health/data/models/pet_health_extended_models.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class AllergyState {
  final List<PetAllergy> allergies;
  final bool isLoading;
  final String? error;

  const AllergyState({
    this.allergies = const [],
    this.isLoading = false,
    this.error,
  });

  AllergyState copyWith({
    List<PetAllergy>? allergies,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => AllergyState(
    allergies: allergies ?? this.allergies,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class AllergyNotifier extends Notifier<AllergyState> {
  HealthRepository get _repo => ref.read(healthRepositoryProvider);

  @override
  AllergyState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return AllergyState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final allergies = await _repo.fetchAllergies(petId);
      if (!ref.mounted) return;
      state = state.copyWith(allergies: allergies, isLoading: false);
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

  Future<void> addAllergy(PetAllergy allergy) async {
    try {
      final saved = await _repo.insertAllergy(allergy);
      state = state.copyWith(allergies: [saved, ...state.allergies]);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthAllergyAddFailed,
        tag: 'AllergyNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthAllergyAddFailed);
    }
  }

  Future<void> removeAllergy(String id) async {
    state = state.copyWith(
      allergies: state.allergies.where((a) => a.id != id).toList(),
    );
    try {
      await _repo.deleteAllergy(id);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthAllergyDeleteFailed,
        tag: 'AllergyNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthAllergyDeleteFailed);
      await refresh();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final allergyProvider = NotifierProvider<AllergyNotifier, AllergyState>(
  AllergyNotifier.new,
);
