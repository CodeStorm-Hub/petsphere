import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/care/data/models/care_badge_model.dart';
import 'package:petfolio/features/care/data/models/pet_care_log_model.dart';
import 'package:petfolio/features/care/data/pet_care_repository.dart';
import 'package:petfolio/features/care/presentation/controllers/care_log_controller.dart';
import 'package:petfolio/features/care/utils/care_gamification_logic.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

@immutable
class CareGamificationState {
  final PetCareGamification? gamification;
  final List<PetCareBadgeUnlock> unlocks;
  final bool isLoading;
  final String? error;
  final String? activePetId;

  const CareGamificationState({
    this.gamification,
    this.unlocks = const [],
    this.isLoading = false,
    this.error,
    this.activePetId,
  });

  int get streakDays {
    // This could be moved to a getter that uses logs, but for now we'll 
    // rely on the gamification model or calculate it from logs if needed.
    return gamification?.bestStreakDays ?? 0; 
  }

  CareGamificationState copyWith({
    PetCareGamification? gamification,
    List<PetCareBadgeUnlock>? unlocks,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? activePetId,
  }) => CareGamificationState(
    gamification: gamification ?? this.gamification,
    unlocks: unlocks ?? this.unlocks,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    activePetId: activePetId ?? this.activePetId,
  );
}

class CareGamificationNotifier extends Notifier<CareGamificationState> {
  final _repo = petCareRepository;

  @override
  CareGamificationState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });

    // Listen to logs to trigger sync/rewards
    ref.listen<CareLogState>(careLogProvider, (prev, next) {
      if (next.recentLogs.isNotEmpty && !next.isLoading) {
        _syncRewards(next.recentLogs);
      }
    });

    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return CareGamificationState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      activePetId: petId,
    );
    try {
      final results = await Future.wait([
        _repo.fetchGamification(petId),
        _repo.fetchUnlocksForPet(petId),
      ]);
      if (!ref.mounted) return;
      state = state.copyWith(
        gamification: results[0] as PetCareGamification?,
        unlocks: results[1] as List<PetCareBadgeUnlock>,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final id = state.activePetId;
    if (id != null) await _load(id);
  }

  Future<void> _syncRewards(List<PetCareLog> logs) async {
    final petId = state.activePetId;
    if (petId == null) return;
    final pet = ref.read(activePetProvider);
    if (pet == null) return;

    // 1. Calculate next gamification state
    // We need current streak. Let's calculate it from logs.
    final streak = _calculateStreak(logs);
    
    final nextGamification = CareGamificationLogic.buildNext(
      current: state.gamification,
      recentLogs: logs,
      streakDays: streak,
      userId: pet.userId,
      petId: petId,
    );

    // 2. Persist if changed
    if (nextGamification != state.gamification) {
      try {
        final saved = await _repo.upsertGamification(nextGamification);
        state = state.copyWith(gamification: saved);
      } catch (e) {
        debugPrint('Failed to sync gamification: $e');
      }
    }

    // 3. Check for new badges
    final newSlugs = CareGamificationLogic.badgeSlugsToUnlock(
      recentLogs: logs,
      streakDays: streak,
      next: nextGamification,
    );

    final existingSlugs = state.unlocks.map((u) => u.badgeSlug).toSet();
    for (final slug in newSlugs) {
      if (!existingSlugs.contains(slug)) {
        try {
          await _repo.insertUnlockIfNew(
            userId: pet.userId,
            petId: petId,
            badgeSlug: slug,
          );
          // Refresh unlocks
          final updatedUnlocks = await _repo.fetchUnlocksForPet(petId);
          state = state.copyWith(unlocks: updatedUnlocks);
        } catch (e) {
          debugPrint('Failed to unlock badge $slug: $e');
        }
      }
    }
  }

  int _calculateStreak(List<PetCareLog> logs) {
    var streak = 0;
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
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
}

final careGamificationProvider = NotifierProvider<CareGamificationNotifier, CareGamificationState>(CareGamificationNotifier.new);

/// Small catalog; safe to refetch (cached in Riverpod as long as provider lives).
final careBadgeDefinitionsProvider = FutureProvider<List<CareBadgeDefinition>>((
  ref,
) {
  return petCareRepository.fetchBadgeDefinitions();
});

/// Badges the user chose to show publicly.
final publicCareBadgeShowcaseProvider =
    FutureProvider.family<List<CareBadgeDefinition>, String>((
      ref,
      userId,
    ) async {
      final unlocks = await petCareRepository.fetchPublicShowcaseUnlocks(
        userId,
      );
      if (unlocks.isEmpty) return const [];
      final defs = await ref.watch(careBadgeDefinitionsProvider.future);
      final bySlug = {for (final d in defs) d.slug: d};
      return [
        for (final u in unlocks)
          if (bySlug.containsKey(u.badgeSlug)) bySlug[u.badgeSlug]!,
      ];
    });
