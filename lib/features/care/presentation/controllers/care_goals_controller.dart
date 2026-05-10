import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:petfolio/features/care/data/models/care_badge_model.dart';
import 'package:petfolio/features/care/data/pet_care_repository.dart';
import 'package:petfolio/features/care/presentation/controllers/care_log_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';


@immutable
class CareGoalsState {

  const CareGoalsState({
    this.onboarding,
    this.isLoading = false,
    this.error,
    this.activePetId,
  });
  final PetCareOnboarding? onboarding;
  final bool isLoading;
  final String? error;
  final String? activePetId;

  CareGoalsState copyWith({
    PetCareOnboarding? onboarding,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? activePetId,
  }) => CareGoalsState(
    onboarding: onboarding ?? this.onboarding,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    activePetId: activePetId ?? this.activePetId,
  );
}

class CareGoalsNotifier extends Notifier<CareGoalsState> {
  final _repo = petCareRepository;

  @override
  CareGoalsState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });

    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return CareGoalsState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true, activePetId: petId);
    try {
      final onboarding = await _repo.fetchOnboarding(petId);
      if (!ref.mounted) return;
      state = state.copyWith(onboarding: onboarding, isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final id = state.activePetId;
    if (id != null) await _load(id);
  }

  Future<void> updateGoals({
    int? calorieGoal,
    int? waterGoalCups,
    int? exerciseGoalMinutes,
  }) async {
    final pet = ref.read(activePetProvider);
    if (pet == null) return;

    // 1. Update Today's Log via CareLogNotifier
    ref.read(careLogProvider.notifier).updateDailyGoals(
      calorieGoal: calorieGoal,
      waterGoalCups: waterGoalCups,
      exerciseGoalMinutes: exerciseGoalMinutes,
    );

    // 2. Update Pet Profile for persistence
    final fields = <String, dynamic>{};
    if (calorieGoal != null) fields['daily_calorie_goal'] = calorieGoal;
    if (waterGoalCups != null) fields['daily_water_goal_cups'] = waterGoalCups;
    
    if (fields.isNotEmpty) {
      await ref.read(petProvider.notifier).updatePet(pet.id, fields);
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> data) async {
    final petId = state.activePetId;
    if (petId == null) return;
    
    state = state.copyWith(isLoading: true);
    try {
      await _repo.saveOnboarding(petId, data, markComplete: true);
      final updated = await _repo.fetchOnboarding(petId);
      if (!ref.mounted) return;
      state = state.copyWith(onboarding: updated, isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final careGoalsProvider = NotifierProvider<CareGoalsNotifier, CareGoalsState>(CareGoalsNotifier.new);

