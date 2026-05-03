import 'package:flutter/material.dart';

/// One item in the daily checklist (Morning Walk, Medication, etc.).
///
/// Persisted as JSON inside [PetCareLog.tasks].
class DailyTask {
  final String key;
  final String title;
  final String subtitle;
  final String iconKey;
  final bool done;

  const DailyTask({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    this.done = false,
  });

  DailyTask copyWith({
    String? title,
    String? subtitle,
    String? iconKey,
    bool? done,
  }) {
    return DailyTask(
      key: key,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconKey: iconKey ?? this.iconKey,
      done: done ?? this.done,
    );
  }

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      key: json['key'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      iconKey: json['icon'] as String? ?? 'checklist',
      done: json['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'subtitle': subtitle,
        'icon': iconKey,
        'done': done,
      };

  /// Resolves [iconKey] to a Material icon. Keys mirror the seed values
  /// in `pet_care_tables.sql`.
  IconData get icon {
    switch (iconKey) {
      case 'medical_services':
        return Icons.medical_services;
      case 'brush':
        return Icons.brush;
      case 'restaurant':
        return Icons.restaurant;
      case 'water_drop':
        return Icons.water_drop;
      case 'shower':
        return Icons.shower;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'checklist':
      default:
        return Icons.checklist_rtl_outlined;
    }
  }

  /// Default checklist used when no log exists yet for a given day.
  static const List<DailyTask> defaults = [
    DailyTask(
      key: 'walk',
      title: 'Morning Walk',
      subtitle: '30 minutes',
      iconKey: 'directions_walk',
    ),
    DailyTask(
      key: 'med',
      title: 'Give Medication',
      subtitle: 'Heartworm pill',
      iconKey: 'medical_services',
    ),
    DailyTask(
      key: 'brush',
      title: 'Brush Coat',
      subtitle: 'Keep it shiny',
      iconKey: 'brush',
    ),
  ];
}

/// Single day's worth of care for one pet — feeding toggles, water cups,
/// task completion, mood, and a snapshot of that day's goals.
@immutable
class PetCareLog {
  /// `null` for an unsaved log that lives only on the client.
  final String? id;
  final String petId;
  final DateTime logDate; // date-only (year/month/day)

  // Feeding
  final bool breakfastFed;
  final bool dinnerFed;
  final int breakfastKcal;
  final int dinnerKcal;
  final String breakfastFood;
  final String dinnerFood;

  // Snack / lunch (optional third meal — useful for puppies/kittens)
  final bool snackFed;
  final int snackKcal;
  final String snackFood;

  // Treat tracking
  final int treatsCount;
  final int treatsKcal;

  // Water
  final int waterCups;

  // Tasks & mood
  final List<DailyTask> tasks;
  final String? mood;

  // Goals snapshot
  final int dailyCalorieGoal;
  final int dailyWaterGoalCups;
  final int dailyExerciseGoalMinutes;

  const PetCareLog({
    this.id,
    required this.petId,
    required this.logDate,
    this.breakfastFed = false,
    this.dinnerFed = false,
    this.breakfastKcal = 250,
    this.dinnerKcal = 250,
    this.breakfastFood = 'Dry Kibble - 1 cup',
    this.dinnerFood = 'Wet Food - 1/2 can',
    this.snackFed = false,
    this.snackKcal = 0,
    this.snackFood = '',
    this.treatsCount = 0,
    this.treatsKcal = 0,
    this.waterCups = 0,
    this.tasks = const [],
    this.mood,
    this.dailyCalorieGoal = 500,
    this.dailyWaterGoalCups = 8,
    this.dailyExerciseGoalMinutes = 30,
  });

  // -------------------------------------------------------------------------
  // Derived helpers used by the UI
  // -------------------------------------------------------------------------
  int get consumedKcal =>
      (breakfastFed ? breakfastKcal : 0) +
      (dinnerFed ? dinnerKcal : 0) +
      (snackFed ? snackKcal : 0) +
      treatsKcal;

  /// Calories from meals only (excluding treats).
  int get mealKcal =>
      (breakfastFed ? breakfastKcal : 0) +
      (dinnerFed ? dinnerKcal : 0) +
      (snackFed ? snackKcal : 0);

  /// Maximum treat calories (10% of daily goal).
  int get maxTreatKcal => (dailyCalorieGoal * 0.1).round();

  /// Whether treat calories exceed the recommended 10% budget.
  bool get treatsOverBudget => treatsKcal > maxTreatKcal;

  double get caloriesProgress => dailyCalorieGoal == 0
      ? 0
      : (consumedKcal / dailyCalorieGoal).clamp(0.0, 1.0);

  double get waterProgress => dailyWaterGoalCups == 0
      ? 0
      : (waterCups / dailyWaterGoalCups).clamp(0.0, 1.0);

  int get completedTasks => tasks.where((t) => t.done).length;

  double get tasksProgress => tasks.isEmpty ? 0 : completedTasks / tasks.length;

  /// "Counts toward the streak" if every checklist task is done OR the
  /// owner has at least toggled both meals + half the water goal.
  bool get isCompleteForStreak {
    if (tasks.isNotEmpty && completedTasks == tasks.length) return true;
    final mealsDone = breakfastFed && dinnerFed;
    final waterMet = waterCups >= (dailyWaterGoalCups / 2).ceil();
    return mealsDone && waterMet;
  }

  PetCareLog copyWith({
    String? id,
    String? petId,
    DateTime? logDate,
    bool? breakfastFed,
    bool? dinnerFed,
    int? breakfastKcal,
    int? dinnerKcal,
    String? breakfastFood,
    String? dinnerFood,
    bool? snackFed,
    int? snackKcal,
    String? snackFood,
    int? treatsCount,
    int? treatsKcal,
    int? waterCups,
    List<DailyTask>? tasks,
    String? mood,
    bool clearMood = false,
    int? dailyCalorieGoal,
    int? dailyWaterGoalCups,
    int? dailyExerciseGoalMinutes,
  }) {
    return PetCareLog(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      logDate: logDate ?? this.logDate,
      breakfastFed: breakfastFed ?? this.breakfastFed,
      dinnerFed: dinnerFed ?? this.dinnerFed,
      breakfastKcal: breakfastKcal ?? this.breakfastKcal,
      dinnerKcal: dinnerKcal ?? this.dinnerKcal,
      breakfastFood: breakfastFood ?? this.breakfastFood,
      dinnerFood: dinnerFood ?? this.dinnerFood,
      snackFed: snackFed ?? this.snackFed,
      snackKcal: snackKcal ?? this.snackKcal,
      snackFood: snackFood ?? this.snackFood,
      treatsCount: treatsCount ?? this.treatsCount,
      treatsKcal: treatsKcal ?? this.treatsKcal,
      waterCups: waterCups ?? this.waterCups,
      tasks: tasks ?? this.tasks,
      mood: clearMood ? null : (mood ?? this.mood),
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyWaterGoalCups: dailyWaterGoalCups ?? this.dailyWaterGoalCups,
      dailyExerciseGoalMinutes: dailyExerciseGoalMinutes ?? this.dailyExerciseGoalMinutes,
    );
  }

  // -------------------------------------------------------------------------
  // Serialisation
  // -------------------------------------------------------------------------
  factory PetCareLog.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'];
    final tasks = (rawTasks is List)
        ? rawTasks
            .whereType<Map>()
            .map((e) => DailyTask.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <DailyTask>[];

    return PetCareLog(
      id: json['id'] as String?,
      petId: json['pet_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      breakfastFed: json['breakfast_fed'] as bool? ?? false,
      dinnerFed: json['dinner_fed'] as bool? ?? false,
      breakfastKcal: (json['breakfast_kcal'] as num?)?.toInt() ?? 250,
      dinnerKcal: (json['dinner_kcal'] as num?)?.toInt() ?? 250,
      breakfastFood: json['breakfast_food'] as String? ?? 'Dry Kibble - 1 cup',
      dinnerFood: json['dinner_food'] as String? ?? 'Wet Food - 1/2 can',
      snackFed: json['snack_fed'] as bool? ?? false,
      snackKcal: (json['snack_kcal'] as num?)?.toInt() ?? 0,
      snackFood: json['snack_food'] as String? ?? '',
      treatsCount: (json['treats_count'] as num?)?.toInt() ?? 0,
      treatsKcal: (json['treats_kcal'] as num?)?.toInt() ?? 0,
      waterCups: (json['water_cups'] as num?)?.toInt() ?? 0,
      tasks: tasks.isEmpty ? List.of(DailyTask.defaults) : tasks,
      mood: json['mood'] as String?,
      dailyCalorieGoal: (json['daily_calorie_goal'] as num?)?.toInt() ?? 500,
      dailyWaterGoalCups: (json['daily_water_goal_cups'] as num?)?.toInt() ?? 8,
      dailyExerciseGoalMinutes: (json['daily_exercise_goal_minutes'] as num?)?.toInt() ?? 30,
    );
  }

  /// JSON suitable for `upsert` — `pet_id` + `log_date` is the natural key
  /// and we omit `id` so Postgres assigns it.
  Map<String, dynamic> toUpsertJson() => {
        'pet_id': petId,
        'log_date':
            '${logDate.year.toString().padLeft(4, '0')}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}',
        'breakfast_fed': breakfastFed,
        'dinner_fed': dinnerFed,
        'breakfast_kcal': breakfastKcal,
        'dinner_kcal': dinnerKcal,
        'breakfast_food': breakfastFood,
        'dinner_food': dinnerFood,
        'snack_fed': snackFed,
        'snack_kcal': snackKcal,
        'snack_food': snackFood,
        'treats_count': treatsCount,
        'treats_kcal': treatsKcal,
        'water_cups': waterCups,
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'mood': mood,
        'daily_calorie_goal': dailyCalorieGoal,
        'daily_water_goal_cups': dailyWaterGoalCups,
        'daily_exercise_goal_minutes': dailyExerciseGoalMinutes,
      };

  /// Builds an empty log for the given pet/day, copying the goal snapshot
  /// from the pet's defaults.
  factory PetCareLog.empty({
    required String petId,
    required DateTime logDate,
    int dailyCalorieGoal = 500,
    int dailyWaterGoalCups = 8,
    int dailyExerciseGoalMinutes = 30,
    List<DailyTask>? taskTemplate,
    int breakfastKcal = 250,
    int dinnerKcal = 250,
  }) {
    final t = taskTemplate;
    return PetCareLog(
      petId: petId,
      logDate: DateTime(logDate.year, logDate.month, logDate.day),
      dailyCalorieGoal: dailyCalorieGoal,
      dailyWaterGoalCups: dailyWaterGoalCups,
      dailyExerciseGoalMinutes: dailyExerciseGoalMinutes,
      breakfastKcal: breakfastKcal,
      dinnerKcal: dinnerKcal,
      tasks: t != null && t.isNotEmpty
          ? [for (final x in t) x]
          : List.of(DailyTask.defaults),
    );
  }
}
