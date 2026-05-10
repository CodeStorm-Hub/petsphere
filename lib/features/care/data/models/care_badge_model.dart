import 'package:flutter/foundation.dart';

/// Onboarding / personalization payload stored in `pet_care_onboarding.data` (private RLS).
@immutable
class PetCareOnboarding {
  const PetCareOnboarding({
    required this.petId,
    required this.data,
    this.completedAt,
  });

  final String petId;
  final Map<String, dynamic> data;
  final DateTime? completedAt;

  bool get isComplete => completedAt != null;

  factory PetCareOnboarding.fromRow(Map<String, dynamic> row) {
    return PetCareOnboarding(
      petId: row['pet_id'] as String,
      data: (row['data'] as Map<String, dynamic>?) ?? const {},
      completedAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetCareOnboarding &&
          runtimeType == other.runtimeType &&
          petId == other.petId &&
          data == other.data &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      petId.hashCode ^ data.hashCode ^ completedAt.hashCode;

  static const kSpecies = 'species';
  static const kAgeBand = 'age_band';
  static const kActivity = 'activity';
  static const kDiet = 'diet_type';
  static const kMultiPet = 'multi_pet_home';
  static const kHealthFocus = 'health_focus';
  static const kUseCustomChecklist = 'use_custom_checklist';
  static const kCustomTasks = 'custom_tasks';

  // Enhanced onboarding keys (Phase 2)
  static const kPersonality = 'personality';
  static const kLivingSituation = 'living_situation';
  static const kGender = 'gender';
  static const kIsNeutered = 'is_neutered';
  static const kPrimaryGoal = 'primary_goal';
  static const kGroomingFrequency = 'grooming_frequency';
  static const kExercisePreferences = 'exercise_preferences';
  static const kKnownConditions = 'known_conditions';
}

@immutable
class CareBadgeDefinition {
  const CareBadgeDefinition({
    required this.slug,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.sortOrder,
  });

  final String slug;
  final String title;
  final String description;
  final String iconEmoji;
  final int sortOrder;

  factory CareBadgeDefinition.fromJson(Map<String, dynamic> json) {
    return CareBadgeDefinition(
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconEmoji: json['icon_emoji'] as String? ?? '🏅',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareBadgeDefinition &&
          runtimeType == other.runtimeType &&
          slug == other.slug &&
          title == other.title &&
          description == other.description &&
          iconEmoji == other.iconEmoji &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      slug.hashCode ^
      title.hashCode ^
      description.hashCode ^
      iconEmoji.hashCode ^
      sortOrder.hashCode;
}

@immutable
class PetCareBadgeUnlock {
  const PetCareBadgeUnlock({
    required this.id,
    required this.petId,
    required this.badgeSlug,
    required this.unlockedAt,
  });

  final String id;
  final String petId;
  final String badgeSlug;
  final DateTime unlockedAt;

  factory PetCareBadgeUnlock.fromJson(Map<String, dynamic> json) {
    return PetCareBadgeUnlock(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      badgeSlug: json['badge_slug'] as String,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetCareBadgeUnlock &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          badgeSlug == other.badgeSlug &&
          unlockedAt == other.unlockedAt;

  @override
  int get hashCode =>
      id.hashCode ^ petId.hashCode ^ badgeSlug.hashCode ^ unlockedAt.hashCode;
}

@immutable
class PetCareGamification {
  const PetCareGamification({
    required this.petId,
    required this.userId,
    required this.totalCarePoints,
    required this.bestStreakDays,
    this.weekStartMonday,
    this.weekCompletedMask = 0,
    this.challenge30dStartedOn,
    this.challenge30dProgress = 0,
    this.lastCarePointAwardedOn,
    this.last30dIncrementOn,
    this.dailyPointAwardDate,
    this.dailyPointAwardAccrued = 0,
    this.streakFreezesAvailable = 2,
    this.streakFreezesUsedThisWeek = 0,
    this.streakFreezeResetOn,
  });

  final String petId;
  final String userId;
  final int totalCarePoints;
  final int bestStreakDays;
  final DateTime? weekStartMonday;
  final int weekCompletedMask;
  final DateTime? challenge30dStartedOn;
  final int challenge30dProgress;
  final DateTime? lastCarePointAwardedOn;
  final DateTime? last30dIncrementOn;

  /// Calendar day (date-only) for which [dailyPointAwardAccrued] is valid.
  final DateTime? dailyPointAwardDate;
  final int dailyPointAwardAccrued;

  /// Streak freeze: number of freezes still available this week (max 2).
  final int streakFreezesAvailable;

  /// Number of streak freezes used in the current week.
  final int streakFreezesUsedThisWeek;

  /// Monday of the week when freeze counters were last reset.
  final DateTime? streakFreezeResetOn;

  factory PetCareGamification.fromJson(Map<String, dynamic> json) {
    return PetCareGamification(
      petId: json['pet_id'] as String,
      userId: json['user_id'] as String,
      totalCarePoints: (json['total_care_points'] as num?)?.toInt() ?? 0,
      bestStreakDays: (json['best_streak_days'] as num?)?.toInt() ?? 0,
      weekStartMonday: json['week_start_monday'] != null
          ? DateTime.parse(json['week_start_monday'] as String)
          : null,
      weekCompletedMask: (json['week_completed_mask'] as num?)?.toInt() ?? 0,
      challenge30dStartedOn: json['challenge_30d_started_on'] != null
          ? DateTime.parse(json['challenge_30d_started_on'] as String)
          : null,
      challenge30dProgress:
          (json['challenge_30d_progress'] as num?)?.toInt() ?? 0,
      lastCarePointAwardedOn: json['last_care_point_awarded_on'] != null
          ? DateTime.parse(json['last_care_point_awarded_on'] as String)
          : null,
      last30dIncrementOn: json['last_30d_increment_on'] != null
          ? DateTime.parse(json['last_30d_increment_on'] as String)
          : null,
      dailyPointAwardDate: json['daily_point_award_date'] != null
          ? DateTime.parse(json['daily_point_award_date'] as String)
          : null,
      dailyPointAwardAccrued:
          (json['daily_point_award_accrued'] as num?)?.toInt() ?? 0,
      streakFreezesAvailable:
          (json['streak_freezes_available'] as num?)?.toInt() ?? 2,
      streakFreezesUsedThisWeek:
          (json['streak_freezes_used_this_week'] as num?)?.toInt() ?? 0,
      streakFreezeResetOn: json['streak_freeze_reset_on'] != null
          ? DateTime.parse(json['streak_freeze_reset_on'] as String)
          : null,
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toUpsertJson() => {
    'pet_id': petId,
    'user_id': userId,
    'total_care_points': totalCarePoints,
    'best_streak_days': bestStreakDays,
    'week_start_monday': weekStartMonday == null
        ? null
        : _fmtDate(weekStartMonday!),
    'week_completed_mask': weekCompletedMask,
    'challenge_30d_started_on': challenge30dStartedOn == null
        ? null
        : _fmtDate(challenge30dStartedOn!),
    'challenge_30d_progress': challenge30dProgress,
    'last_care_point_awarded_on': lastCarePointAwardedOn == null
        ? null
        : _fmtDate(lastCarePointAwardedOn!),
    'last_30d_increment_on': last30dIncrementOn == null
        ? null
        : _fmtDate(last30dIncrementOn!),
    'daily_point_award_date': dailyPointAwardDate == null
        ? null
        : _fmtDate(dailyPointAwardDate!),
    'daily_point_award_accrued': dailyPointAwardAccrued,
    'streak_freezes_available': streakFreezesAvailable,
    'streak_freezes_used_this_week': streakFreezesUsedThisWeek,
    'streak_freeze_reset_on': streakFreezeResetOn == null
        ? null
        : _fmtDate(streakFreezeResetOn!),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetCareGamification &&
          runtimeType == other.runtimeType &&
          petId == other.petId &&
          userId == other.userId &&
          totalCarePoints == other.totalCarePoints &&
          bestStreakDays == other.bestStreakDays &&
          weekStartMonday == other.weekStartMonday &&
          weekCompletedMask == other.weekCompletedMask &&
          challenge30dStartedOn == other.challenge30dStartedOn &&
          challenge30dProgress == other.challenge30dProgress &&
          lastCarePointAwardedOn == other.lastCarePointAwardedOn &&
          last30dIncrementOn == other.last30dIncrementOn &&
          dailyPointAwardDate == other.dailyPointAwardDate &&
          dailyPointAwardAccrued == other.dailyPointAwardAccrued &&
          streakFreezesAvailable == other.streakFreezesAvailable &&
          streakFreezesUsedThisWeek == other.streakFreezesUsedThisWeek &&
          streakFreezeResetOn == other.streakFreezeResetOn;

  @override
  int get hashCode =>
      petId.hashCode ^
      userId.hashCode ^
      totalCarePoints.hashCode ^
      bestStreakDays.hashCode ^
      weekStartMonday.hashCode ^
      weekCompletedMask.hashCode ^
      challenge30dStartedOn.hashCode ^
      challenge30dProgress.hashCode ^
      lastCarePointAwardedOn.hashCode ^
      last30dIncrementOn.hashCode ^
      dailyPointAwardDate.hashCode ^
      dailyPointAwardAccrued.hashCode ^
      streakFreezesAvailable.hashCode ^
      streakFreezesUsedThisWeek.hashCode ^
      streakFreezeResetOn.hashCode;
}
