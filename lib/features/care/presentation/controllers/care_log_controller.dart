import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/care/data/models/pet_care_log_model.dart';
import 'package:petfolio/features/care/data/pet_care_repository.dart';
import 'package:petfolio/features/care/data/care_cache.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

@immutable
class CareLogState {
  final List<PetCareLog> recentLogs;
  final bool isLoading;
  final String? error;
  final String? activePetId;

  const CareLogState({
    this.recentLogs = const [],
    this.isLoading = false,
    this.error,
    this.activePetId,
  });

  PetCareLog? get todayLog => recentLogs.isEmpty ? null : recentLogs.first;

  int get streakDays {
    var streak = 0;
    for (var i = 0; i < recentLogs.length; i++) {
      final log = recentLogs[i];
      if (log.isCompleteForStreak) {
        streak++;
      } else if (i == 0) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  List<bool> get streakFlags {
    final byOldest = recentLogs.reversed.toList();
    return [for (final log in byOldest) log.isCompleteForStreak];
  }

  CareLogState copyWith({
    List<PetCareLog>? recentLogs,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? activePetId,
  }) => CareLogState(
    recentLogs: recentLogs ?? this.recentLogs,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    activePetId: activePetId ?? this.activePetId,
  );
}

class CareLogNotifier extends Notifier<CareLogState> {
  final _repo = petCareRepository;
  Timer? _saveDebounce;

  @override
  CareLogState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });
    
    ref.onDispose(() {
      _saveDebounce?.cancel();
    });

    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return CareLogState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      activePetId: petId,
    );

    // 1. Load from cache
    final pet = ref.read(activePetProvider);
    if (pet != null) {
      final cached = await CareCache.loadLogs(
        petId,
        dailyCalorieGoal: pet.dailyCalorieGoal ?? 500,
        dailyWaterGoalCups: pet.dailyWaterGoalCups ?? 8,
      );
      if (cached.isNotEmpty && state.activePetId == petId) {
        state = state.copyWith(recentLogs: cached);
      }
    }

    // 2. Fetch from repository
    try {
      final logs = await _repo.fetchRecentLogs(
        petId,
        dailyCalorieGoal: pet?.dailyCalorieGoal ?? 500,
        dailyWaterGoalCups: pet?.dailyWaterGoalCups ?? 8,
      );
      if (!ref.mounted) return;
      state = state.copyWith(
        recentLogs: logs,
        isLoading: false,
      );
      unawaited(CareCache.saveLogs(petId, logs));
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final id = state.activePetId;
    if (id != null) await _load(id);
  }

  void updateTodayLog(PetCareLog updated) {
    if (state.recentLogs.isEmpty) return;
    
    final newLogs = List<PetCareLog>.from(state.recentLogs);
    newLogs[0] = updated;
    state = state.copyWith(recentLogs: newLogs);
    
    _scheduleSave();
  }

  void setSnackFed(bool fed) {
    final today = state.todayLog;
    if (today == null || today.snackFed == fed) return;
    updateTodayLog(today.copyWith(snackFed: fed));
  }

  void setTreats({required int count, required int kcal}) {
    final today = state.todayLog;
    if (today == null) return;
    updateTodayLog(today.copyWith(treatsCount: count, treatsKcal: kcal));
  }

  void addTreat({int kcalPerTreat = 30}) {
    final today = state.todayLog;
    if (today == null) return;
    updateTodayLog(
      today.copyWith(
        treatsCount: today.treatsCount + 1,
        treatsKcal: today.treatsKcal + kcalPerTreat,
      ),
    );
  }

  void updateDailyGoals({
    int? calorieGoal,
    int? waterGoalCups,
    int? exerciseGoalMinutes,
  }) {
    final today = state.todayLog;
    if (today == null) return;
    updateTodayLog(today.copyWith(
      dailyCalorieGoal: calorieGoal,
      dailyWaterGoalCups: waterGoalCups,
      dailyExerciseGoalMinutes: exerciseGoalMinutes,
    ));

    // Also update the pet profile so goals persist for future days
    final activePet = ref.read(activePetProvider);
    if (activePet != null) {
      final fields = <String, dynamic>{};
      if (calorieGoal != null) fields['daily_calorie_goal'] = calorieGoal;
      if (waterGoalCups != null) {
        fields['daily_water_goal_cups'] = waterGoalCups;
      }
      if (exerciseGoalMinutes != null) {
        fields['daily_exercise_goal_minutes'] = exerciseGoalMinutes;
      }
      if (fields.isNotEmpty) {
        ref.read(petProvider.notifier).updatePet(activePet.id, fields);
      }
    }
  }

  void toggleTask(String taskKey) {
    final today = state.todayLog;
    if (today == null) return;
    final updated = [
      for (final t in today.tasks)
        if (t.key == taskKey) t.copyWith(done: !t.done) else t,
    ];
    updateTodayLog(today.copyWith(tasks: updated));
  }

  void setBreakfastFed(bool fed) {
    final today = state.todayLog;
    if (today == null || today.breakfastFed == fed) return;
    updateTodayLog(today.copyWith(breakfastFed: fed));
  }

  void setDinnerFed(bool fed) {
    final today = state.todayLog;
    if (today == null || today.dinnerFed == fed) return;
    updateTodayLog(today.copyWith(dinnerFed: fed));
  }

  void setWaterCups(int cups) {
    final today = state.todayLog;
    if (today == null) return;
    final clamped = cups.clamp(0, today.dailyWaterGoalCups);
    if (clamped == today.waterCups) return;
    updateTodayLog(today.copyWith(waterCups: clamped));
  }

  void setMood(String? mood) {
    final today = state.todayLog;
    if (today == null) return;
    if (today.mood == mood) return;
    updateTodayLog(today.copyWith(mood: mood, clearMood: mood == null));
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 1500), () async {
      final today = state.todayLog;
      if (today != null) {
        try {
          await _repo.upsertLog(today);
          if (state.activePetId != null) {
            unawaited(CareCache.saveLogs(state.activePetId!, state.recentLogs));
          }
        } catch (e) {
          state = state.copyWith(error: 'Failed to save log: $e');
        }
      }
    });
  }
}

final careLogProvider = NotifierProvider<CareLogNotifier, CareLogState>(CareLogNotifier.new);

/// Convenience: today's log for the active pet.
final todayCareLogProvider = Provider<PetCareLog?>((ref) {
  return ref.watch(careLogProvider).todayLog;
});
