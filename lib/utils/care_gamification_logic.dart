import '../models/care_badge_model.dart';
import '../models/pet_care_log_model.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _mondayOfWeek(DateTime d) {
  final x = _dateOnly(d);
  return x.subtract(Duration(days: x.weekday - 1));
}

/// Target care points for "today" from the log (capped at 10 / day for scoring).
/// Incomplete days: 2 per completed task. Complete care day: 10.
/// This maps clearly to "task slices + top-up" without double-counting.
int wantedDailyCarePoints(PetCareLog? todayLog) {
  if (todayLog == null) return 0;
  if (todayLog.isCompleteForStreak) {
    // Full care day: same max daily credit as the legacy single +10 award.
    return 10;
  }
  return 2 * todayLog.completedTasks;
}

/// Pure merge for persisting to `pet_care_gamification` from the local log window.
class CareGamificationLogic {
  CareGamificationLogic._();

  static PetCareGamification buildNext({
    required PetCareGamification? current,
    required List<PetCareLog> recentLogs,
    required int streakDays,
    required String userId,
    required String petId,
  }) {
    final now = _dateOnly(DateTime.now());
    var total = current?.totalCarePoints ?? 0;
    var best = current?.bestStreakDays ?? 0;
    if (streakDays > best) best = streakDays;

    final mon = _mondayOfWeek(now);
    var mask = 0;
    for (var i = 0; i < 7; i++) {
      final d = mon.add(Duration(days: i));
      for (final log in recentLogs) {
        if (_dateOnly(log.logDate) == d && log.isCompleteForStreak) {
          mask |= 1 << i;
        }
      }
    }

    var started = current?.challenge30dStartedOn;
    var c30 = current?.challenge30dProgress ?? 0;
    var last30 = current?.last30dIncrementOn;
    var lastPoint = current?.lastCarePointAwardedOn;

    var awardDate = current?.dailyPointAwardDate;
    var accrued = current?.dailyPointAwardAccrued ?? 0;

    if (awardDate == null || _dateOnly(awardDate) != now) {
      // New local day: reset the running award tracker (lifetime total unchanged).
      awardDate = now;
      accrued = 0;
    }

    // One-time bridge for rows that used legacy +10 / day (no new columns on server yet).
    if (current != null &&
        current.dailyPointAwardDate == null &&
        current.lastCarePointAwardedOn != null &&
        _dateOnly(current.lastCarePointAwardedOn!) == now) {
      awardDate = now;
      accrued = 10;
    }

    final todayLog = recentLogs.isEmpty ? null : recentLogs.first;
    final todayComplete = todayLog?.isCompleteForStreak ?? false;

    final want = wantedDailyCarePoints(todayLog);
    final delta = want > accrued ? want - accrued : 0;
    if (delta > 0) {
      total += delta;
      accrued += delta;
      lastPoint = now;
    }

    if (todayComplete) {
      if (last30 == null || _dateOnly(last30) != now) {
        started ??= now;
        if (c30 < 30) {
          c30 += 1;
        }
        last30 = now;
      }
    }

    // Streak freeze management
    var freezesAvailable = current?.streakFreezesAvailable ?? 2;
    var freezesUsedThisWeek = current?.streakFreezesUsedThisWeek ?? 0;
    var freezeResetOn = current?.streakFreezeResetOn;

    // Reset weekly freeze count on Monday
    if (freezeResetOn == null || _mondayOfWeek(now) != _dateOnly(freezeResetOn)) {
      freezesUsedThisWeek = 0;
      freezeResetOn = mon;
      freezesAvailable = 2;
    }

    return PetCareGamification(
      petId: petId,
      userId: userId,
      totalCarePoints: total,
      bestStreakDays: best,
      weekStartMonday: mon,
      weekCompletedMask: mask,
      challenge30dStartedOn: started,
      challenge30dProgress: c30,
      lastCarePointAwardedOn: lastPoint,
      last30dIncrementOn: last30,
      dailyPointAwardDate: awardDate,
      dailyPointAwardAccrued: accrued,
      streakFreezesAvailable: freezesAvailable,
      streakFreezesUsedThisWeek: freezesUsedThisWeek,
      streakFreezeResetOn: freezeResetOn,
    );
  }

  /// Determines which badges should be unlocked based on current progress.
  static List<String> badgeSlugsToUnlock({
    required List<PetCareLog> recentLogs,
    required int streakDays,
    required PetCareGamification next,
  }) {
    final out = <String>[];

    // ── First log badge ─────────────────────────────────────────────────────
    final anyComplete = recentLogs.any((l) => l.isCompleteForStreak);
    if (anyComplete || next.totalCarePoints > 0) {
      out.add('first_log');
    }

    // ── Streak badges ───────────────────────────────────────────────────────
    if (streakDays >= 3) out.add('streak_3');
    if (streakDays >= 7) out.add('streak_7');
    if (streakDays >= 14) out.add('streak_14');

    // ── Week completion badges ──────────────────────────────────────────────
    var completedDaysInWeek = 0;
    for (var i = 0; i < 7; i++) {
      if ((next.weekCompletedMask & (1 << i)) != 0) completedDaysInWeek++;
    }
    if (completedDaysInWeek >= 5) out.add('week_complete');
    if (completedDaysInWeek >= 7) out.add('perfect_week');

    // ── 30-day challenge badge ──────────────────────────────────────────────
    if (next.challenge30dProgress >= 30) out.add('challenge_30');

    // ── Point milestones ────────────────────────────────────────────────────
    if (next.totalCarePoints >= 100) out.add('points_100');
    if (next.totalCarePoints >= 500) out.add('points_500');

    // ── Feeding consistency badge (7 consecutive days feeding tracked) ─────
    if (_feedingStreak(recentLogs) >= 7) out.add('nutrition_ninja');

    // ── Water goal badge (7 consecutive days meeting water goal) ───────────
    if (_waterGoalStreak(recentLogs) >= 7) out.add('hydration_station');

    // ── Mood tracking badge (7 consecutive days with mood logged) ──────────
    if (_moodStreak(recentLogs) >= 7) out.add('mood_tracker');

    return out;
  }

  /// Counts consecutive days (from today backward) where both meals were fed.
  static int _feedingStreak(List<PetCareLog> logs) {
    var streak = 0;
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      if (log.breakfastFed && log.dinnerFed) {
        streak++;
      } else if (i == 0) {
        // Today might still be in progress
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Counts consecutive days (from today backward) where water goal was met.
  static int _waterGoalStreak(List<PetCareLog> logs) {
    var streak = 0;
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      if (log.waterCups >= log.dailyWaterGoalCups) {
        streak++;
      } else if (i == 0) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Counts consecutive days (from today backward) where mood was logged.
  static int _moodStreak(List<PetCareLog> logs) {
    var streak = 0;
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      if (log.mood != null && log.mood!.isNotEmpty) {
        streak++;
      } else if (i == 0) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Whether the streak should be preserved by using a freeze.
  /// Returns true if a freeze was used (caller should persist the updated state).
  static bool shouldUseStreakFreeze({
    required PetCareGamification current,
    required bool todayIncomplete,
  }) {
    if (!todayIncomplete) return false;
    if (current.streakFreezesAvailable <= 0) return false;
    if (current.streakFreezesUsedThisWeek >= 2) return false;
    return true;
  }
}
