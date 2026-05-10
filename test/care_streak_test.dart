import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care/data/models/pet_care_log_model.dart';

void main() {
  test(
    'streak counts consecutive complete days (today in-progress allowed)',
    () {
      final today = DateTime(2026, 4, 27);
      final logs = <PetCareLog>[
        PetCareLog.empty(
          petId: 'p',
          logDate: today,
        ),
        // yesterday complete
        PetCareLog(
          petId: 'p',
          logDate: today.subtract(const Duration(days: 1)),
          breakfastFed: true,
          dinnerFed: true,
          waterCups: 8,
          tasks: [for (final t in DailyTask.defaults) t.copyWith(done: true)],
        ),
      ];
      // streakDays logic (mirrors PetCareState) for two-day list
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
      expect(streak, 1);
    },
  );
}
