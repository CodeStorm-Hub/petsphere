import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/care_badge_model.dart';
import '../models/pet_care_log_model.dart';
import '../models/pet_health_models.dart';
import '../models/pet_model.dart';
import '../repositories/pet_care_repository.dart';
import '../utils/care_cache.dart';
import '../utils/care_gamification_logic.dart';
import '../utils/care_personalization.dart';
export '../models/pet_health_models.dart' show PetSymptom;
import 'pet_controller.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
@immutable
class PetCareState {
  /// Most recent [recentDays] logs for the active pet, newest first.
  /// Index 0 is always today (a freshly-built empty log if nothing was saved).
  final List<PetCareLog> recentLogs;
  final List<PetWeightLog> recentWeights;
  final List<PetVetAppointment> upcomingAppointments;
  final List<PetVaccination> vaccinations;
  final List<PetSymptom> symptoms;
  final PetCareOnboarding? onboarding;
  final PetCareGamification? gamification;
  final List<PetCareBadgeUnlock> unlocks;
  final bool isLoading;
  final String? error;
  final String? activePetId;

  const PetCareState({
    this.recentLogs = const [],
    this.recentWeights = const [],
    this.upcomingAppointments = const [],
    this.vaccinations = const [],
    this.symptoms = const [],
    this.onboarding,
    this.gamification,
    this.unlocks = const [],
    this.isLoading = false,
    this.error,
    this.activePetId,
  });

  PetCareLog? get todayLog => recentLogs.isEmpty ? null : recentLogs.first;

  /// Streak = number of consecutive past-or-current days for which the log
  /// counts as complete. If today is incomplete, the streak still reflects
  /// the unbroken trailing days behind it.
  int get streakDays {
    var streak = 0;
    for (var i = 0; i < recentLogs.length; i++) {
      final log = recentLogs[i];
      // Today is allowed to be in-progress: only break the streak when we
      // hit an *earlier* day that's incomplete.
      if (log.isCompleteForStreak) {
        streak++;
      } else if (i == 0) {
        continue; // today still in progress — keep counting
      } else {
        break;
      }
    }
    return streak;
  }

  /// Boolean flag per recent day, oldest -> newest, length = recentLogs.length.
  /// Used to render the streak chip row.
  List<bool> get streakFlags {
    final byOldest = recentLogs.reversed.toList();
    return [for (final log in byOldest) log.isCompleteForStreak];
  }

  List<PetSymptom> get activeSymptoms =>
      symptoms.where((s) => !s.isResolved).toList();

  List<PetSymptom> get resolvedSymptoms =>
      symptoms.where((s) => s.isResolved).toList();

  PetCareState copyWith({
    List<PetCareLog>? recentLogs,
    List<PetWeightLog>? recentWeights,
    List<PetVetAppointment>? upcomingAppointments,
    List<PetVaccination>? vaccinations,
    List<PetSymptom>? symptoms,
    PetCareOnboarding? onboarding,
    PetCareGamification? gamification,
    List<PetCareBadgeUnlock>? unlocks,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? activePetId,
    bool clearActivePet = false,
  }) {
    return PetCareState(
      recentLogs: recentLogs ?? this.recentLogs,
      recentWeights: recentWeights ?? this.recentWeights,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      vaccinations: vaccinations ?? this.vaccinations,
      symptoms: symptoms ?? this.symptoms,
      onboarding: onboarding ?? this.onboarding,
      gamification: gamification ?? this.gamification,
      unlocks: unlocks ?? this.unlocks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      activePetId: clearActivePet ? null : (activePetId ?? this.activePetId),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
/// Manages care state for the *currently active* pet.
///
/// The notifier listens to [activePetProvider] so it transparently re-loads
/// data whenever the user switches pets. All UI mutations go through methods
/// on this class so they end up persisted to Supabase via
/// [PetCareRepository] — no more ephemeral widget state.
class PetCareNotifier extends Notifier<PetCareState> {
  static const _recentDays = 7;
  Timer? _saveDebounce;
  int _loadGen = 0;

  @override
  PetCareState build() {
    ref.listen<PetModel?>(activePetProvider, (prev, next) {
      if (prev?.id == next?.id) return;
      if (next == null) {
        state = const PetCareState();
        return;
      }
      _loadAll(next);
    });

    ref.onDispose(() {
      _saveDebounce?.cancel();
    });

    final activePet = ref.read(activePetProvider);
    if (activePet != null) {
      // Defer until after build returns so we don't mutate during construction.
      Future.microtask(() => _loadAll(activePet));
    }

    return const PetCareState();
  }

  // -------------------------------------------------------------------------
  // Loading
  // -------------------------------------------------------------------------
  Future<void> _loadAll(PetModel pet) async {
    final gen = ++_loadGen;
    final calorieGoal = pet.dailyCalorieGoal ?? 500;
    final waterGoal = pet.dailyWaterGoalCups ?? 8;

    // ── 1. Serve stale cache immediately so UI is never blank ──────────────
    final cachedLogs = await CareCache.loadLogs(
      pet.id,
      dailyCalorieGoal: calorieGoal,
      dailyWaterGoalCups: waterGoal,
    );
    final cachedWeights = await CareCache.loadWeights(pet.id);

    if (gen != _loadGen) return;

    if (cachedLogs.isNotEmpty || cachedWeights.isNotEmpty) {
      state = state.copyWith(
        activePetId: pet.id,
        recentLogs: cachedLogs.isNotEmpty ? cachedLogs : state.recentLogs,
        recentWeights:
            cachedWeights.isNotEmpty ? cachedWeights : state.recentWeights,
        isLoading: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        activePetId: pet.id,
      );
    }

    // ── 2. Fetch live data ─────────────────────────────────────────────────
    try {
      final results = await Future.wait([
        petCareRepository.fetchRecentLogs(
          pet.id,
          days: _recentDays,
          dailyCalorieGoal: calorieGoal,
          dailyWaterGoalCups: waterGoal,
        ),
        petCareRepository.fetchRecentWeights(pet.id, days: _recentDays),
        petCareRepository.fetchUpcomingAppointments(pet.id),
        petCareRepository.fetchVaccinations(pet.id),
        petCareRepository.fetchSymptoms(pet.id),
        petCareRepository.fetchOnboarding(pet.id),
        petCareRepository.fetchGamification(pet.id),
        petCareRepository.fetchUnlocksForPet(pet.id),
      ]);

      if (gen != _loadGen) return;

      var freshLogs = results[0] as List<PetCareLog>;
      final freshWeights = results[1] as List<PetWeightLog>;
      final onboarding = results[5] as PetCareOnboarding?;
      freshLogs = applyOnboardingToCareLogs(freshLogs, onboarding);

      // ── 3. Write back to cache ───────────────────────────────────────────
      unawaited(CareCache.saveLogs(pet.id, freshLogs));
      unawaited(CareCache.saveWeights(pet.id, freshWeights));

      state = state.copyWith(
        recentLogs: freshLogs,
        recentWeights: freshWeights,
        upcomingAppointments: results[2] as List<PetVetAppointment>,
        vaccinations: results[3] as List<PetVaccination>,
        symptoms: results[4] as List<PetSymptom>,
        onboarding: onboarding,
        gamification: results[6] as PetCareGamification?,
        unlocks: results[7] as List<PetCareBadgeUnlock>,
        isLoading: false,
      );
      unawaited(_syncCareRewards(pet));
    } catch (e, st) {
      if (gen != _loadGen) return;
      debugPrint('[pet_care] load failed: $e\n$st');
      // Keep stale cache — only mark loading done and surface the error.
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final pet = ref.read(activePetProvider);
    if (pet != null) await _loadAll(pet);
  }

  // -------------------------------------------------------------------------
  // Mutations — apply optimistically then persist with debounce
  // -------------------------------------------------------------------------

  void updateGoals({
    int? calorieGoal,
    int? waterGoalCups,
    int? exerciseGoalMinutes,
  }) {
    final today = state.todayLog;
    if (today == null) return;
    _replaceToday(today.copyWith(
      dailyCalorieGoal: calorieGoal,
      dailyWaterGoalCups: waterGoalCups,
      dailyExerciseGoalMinutes: exerciseGoalMinutes,
    ));
    _scheduleSave();
  }

  void toggleTask(String taskKey) {
    final today = state.todayLog;
    if (today == null) return;
    final updated = [
      for (final t in today.tasks)
        if (t.key == taskKey) t.copyWith(done: !t.done) else t,
    ];
    _replaceToday(today.copyWith(tasks: updated));
    _scheduleSave();
  }

  void setBreakfastFed(bool fed) {
    final today = state.todayLog;
    if (today == null || today.breakfastFed == fed) return;
    _replaceToday(today.copyWith(breakfastFed: fed));
    _scheduleSave();
  }

  void setDinnerFed(bool fed) {
    final today = state.todayLog;
    if (today == null || today.dinnerFed == fed) return;
    _replaceToday(today.copyWith(dinnerFed: fed));
    _scheduleSave();
  }

  void setWaterCups(int cups) {
    final today = state.todayLog;
    if (today == null) return;
    final clamped = cups.clamp(0, today.dailyWaterGoalCups);
    if (clamped == today.waterCups) return;
    _replaceToday(today.copyWith(waterCups: clamped));
    _scheduleSave();
  }

  void setMood(String? mood) {
    final today = state.todayLog;
    if (today == null) return;
    if (today.mood == mood) return;
    _replaceToday(today.copyWith(mood: mood, clearMood: mood == null));
    _scheduleSave();
  }

  /// Sets whether the optional snack/lunch meal was fed.
  void setSnackFed(bool fed) {
    final today = state.todayLog;
    if (today == null || today.snackFed == fed) return;
    _replaceToday(today.copyWith(snackFed: fed));
    _scheduleSave();
  }

  /// Updates treat count and estimated treat calories.
  void setTreats({required int count, required int kcal}) {
    final today = state.todayLog;
    if (today == null) return;
    _replaceToday(today.copyWith(treatsCount: count, treatsKcal: kcal));
    _scheduleSave();
  }

  /// Increments treat count by 1 and adds estimated kcal per treat.
  void addTreat({int kcalPerTreat = 30}) {
    final today = state.todayLog;
    if (today == null) return;
    _replaceToday(today.copyWith(
      treatsCount: today.treatsCount + 1,
      treatsKcal: today.treatsKcal + kcalPerTreat,
    ));
    _scheduleSave();
  }

  /// Saves a new symptom observation.
  Future<void> logSymptom({
    required String symptomType,
    required String severity,
    String? notes,
  }) async {
    final petId = state.activePetId;
    if (petId == null) return;
    try {
      final saved = await petCareRepository.insertSymptom(
        petId: petId,
        symptomType: symptomType,
        severity: severity,
        notes: notes,
      );
      state = state.copyWith(symptoms: [saved, ...state.symptoms]);
    } catch (e) {
      debugPrint('[pet_care] logSymptom failed: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Marks an active symptom as resolved.
  Future<void> resolveSymptom(String symptomId) async {
    try {
      final resolved = await petCareRepository.resolveSymptom(symptomId);
      state = state.copyWith(
        symptoms: [
          for (final s in state.symptoms)
            if (s.id == symptomId) resolved else s,
        ],
      );
    } catch (e) {
      debugPrint('[pet_care] resolveSymptom failed: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Immediately persists today's weight and refreshes the chart series.
  Future<void> logWeight({
    required double weight,
    String? notes,
    int? bcsScore,
  }) async {
    final petId = state.activePetId;
    if (petId == null) return;
    final today = DateTime.now();

    try {
      await petCareRepository.upsertWeight(
        PetWeightLog(
          petId: petId,
          logDate: today,
          weightLbs: weight,
          notes: notes,
          bcsScore: bcsScore,
        ),
      );
      final fresh = await petCareRepository.fetchRecentWeights(
        petId,
        days: _recentDays,
      );
      state = state.copyWith(recentWeights: fresh);
    } catch (e) {
      debugPrint('[pet_care] logWeight failed: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // -------------------------------------------------------------------------
  // Persistence helpers
  // -------------------------------------------------------------------------
  void _replaceToday(PetCareLog updated) {
    final logs = [updated, ...state.recentLogs.skip(1)];
    state = state.copyWith(recentLogs: logs);
  }

  /// Coalesces rapid edits (multiple toggles in a row) into a single PATCH.
  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), _flushTodayLog);
  }

  Future<void> _flushTodayLog() async {
    final today = state.todayLog;
    if (today == null) return;
    try {
      final saved = await petCareRepository.upsertLog(today);
      // Keep the server-assigned id but otherwise prefer the local copy
      // (the user may have toggled more between save & response).
      final logs = state.recentLogs;
      if (logs.isNotEmpty && logs.first.id == null) {
        state = state.copyWith(
          recentLogs: [logs.first.copyWith(id: saved.id), ...logs.skip(1)],
        );
      }
      final pet = ref.read(activePetProvider);
      if (pet != null) unawaited(_syncCareRewards(pet));
    } catch (e) {
      debugPrint('[pet_care] save failed: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _syncCareRewards(PetModel pet) async {
    if (state.activePetId != pet.id) return;
    try {
      final next = CareGamificationLogic.buildNext(
        current: state.gamification,
        recentLogs: state.recentLogs,
        streakDays: state.streakDays,
        userId: pet.userId,
        petId: pet.id,
      );
      final saved = await petCareRepository.upsertGamification(next);
      final toUnlock = CareGamificationLogic.badgeSlugsToUnlock(
        recentLogs: state.recentLogs,
        streakDays: state.streakDays,
        next: saved,
      );
      for (final slug in toUnlock) {
        await petCareRepository.insertUnlockIfNew(
          userId: pet.userId,
          petId: pet.id,
          badgeSlug: slug,
        );
      }
      final fresh = await petCareRepository.fetchUnlocksForPet(pet.id);
      if (state.activePetId == pet.id) {
        state = state.copyWith(
          gamification: saved,
          unlocks: fresh,
        );
      }
    } catch (e) {
      debugPrint('[pet_care] _syncCareRewards: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final petCareProvider =
    NotifierProvider<PetCareNotifier, PetCareState>(PetCareNotifier.new);

/// Convenience: today's log for the active pet (or `null` while loading /
/// when no pet is selected).
final todayCareLogProvider = Provider<PetCareLog?>((ref) {
  return ref.watch(petCareProvider).todayLog;
});

/// Small catalog; safe to refetch (cached in Riverpod as long as provider lives).
final careBadgeDefinitionsProvider =
    FutureProvider<List<CareBadgeDefinition>>((ref) {
  return petCareRepository.fetchBadgeDefinitions();
});

/// Badges the user chose to show publicly ([profiles.public_care_badge_slugs]).
final publicCareBadgeShowcaseProvider =
    FutureProvider.family<List<CareBadgeDefinition>, String>(
        (ref, userId) async {
  final unlocks = await petCareRepository.fetchPublicShowcaseUnlocks(userId);
  if (unlocks.isEmpty) return const [];
  final defs = await ref.watch(careBadgeDefinitionsProvider.future);
  final bySlug = {for (final d in defs) d.slug: d};
  return [
    for (final u in unlocks)
      if (bySlug.containsKey(u.badgeSlug)) bySlug[u.badgeSlug]!,
  ];
});
