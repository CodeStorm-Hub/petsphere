import 'package:flutter_test/flutter_test.dart';

import 'package:petfolio/features/care/data/models/care_badge_model.dart';
import 'package:petfolio/features/care/data/models/pet_care_log_model.dart'
    show DailyTask, PetCareLog;
import 'package:petfolio/features/care/utils/care_gamification_logic.dart';

void main() {
  group('CareGamificationLogic', () {
    test('buildNext awards points when today log completes streak', () {
      final today = DateTime.now();
      final log = PetCareLog.empty(petId: 'p1', logDate: today).copyWith(
        breakfastFed: true,
        dinnerFed: true,
        waterCups: 8,
        dailyWaterGoalCups: 8,
      );
      final next = CareGamificationLogic.buildNext(
        current: null,
        recentLogs: [log],
        streakDays: 1,
        userId: 'u1',
        petId: 'p1',
      );
      expect(next.totalCarePoints, 10);
      expect(next.bestStreakDays, 1);
    });

    test('buildNext awards 2 per task when day not yet complete', () {
      final today = DateTime.now();
      final t = List<DailyTask>.from(DailyTask.defaults);
      t[0] = t[0].copyWith(done: true);
      t[1] = t[1].copyWith(done: true);
      final log = PetCareLog(
        petId: 'p1',
        logDate: today,
        tasks: t,
      );
      final next = CareGamificationLogic.buildNext(
        current: null,
        recentLogs: [log],
        streakDays: 0,
        userId: 'u1',
        petId: 'p1',
      );
      expect(next.totalCarePoints, 4);
    });

    test('badgeSlugsToUnlock includes streak_7 when streakDays >= 7', () {
      final logs = <PetCareLog>[
        PetCareLog.empty(petId: 'p1', logDate: DateTime.now()),
      ];
      const g = PetCareGamification(
        petId: 'p1',
        userId: 'u1',
        totalCarePoints: 0,
        bestStreakDays: 7,
      );
      final slugs = CareGamificationLogic.badgeSlugsToUnlock(
        recentLogs: logs,
        streakDays: 7,
        next: g,
      );
      expect(slugs, contains('streak_7'));
    });
  });
}
