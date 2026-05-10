import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petsphere/features/care/data/models/care_badge_model.dart';
import 'package:petsphere/features/care/data/models/pet_activity_log_model.dart';
import 'package:petsphere/features/care/data/models/pet_care_log_model.dart';
import 'package:petsphere/features/health/data/models/pet_health_models.dart';
import 'package:petsphere/core/constants/supabase_config.dart';

export 'package:petsphere/features/health/data/models/pet_health_models.dart' show PetSymptom;

/// Data access for the Pet Care feature.
///
/// Wraps `pet_care_logs`, `pet_weight_logs`, `pet_vet_appointments`, and
/// `pet_vaccinations`. RLS in Supabase already restricts every row to the
/// authenticated owner, so callers don't need to pass `user_id` explicitly.
class PetCareRepository {
  // ===========================================================================
  // CARE LOGS
  // ===========================================================================

  /// Fetches the most recent [days] daily logs (newest first), filling any
  /// missing dates with empty client-side records so the UI can render a
  /// continuous timeline.
  Future<List<PetCareLog>> fetchRecentLogs(
    String petId, {
    int days = 7,
    int dailyCalorieGoal = 500,
    int dailyWaterGoalCups = 8,
  }) async {
    final today = DateTime.now();
    final startDate = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: days - 1));
    final startStr = _dateOnly(startDate);

    final raw = await supabase
        .from('pet_care_logs')
        .select()
        .eq('pet_id', petId)
        .gte('log_date', startStr)
        .order('log_date', ascending: false);

    final byDate = <String, PetCareLog>{
      for (final row in raw)
        row['log_date'] as String: PetCareLog.fromJson(row),
    };

    return List.generate(days, (i) {
      final date = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: i));
      final key = _dateOnly(date);
      return byDate[key] ??
          PetCareLog.empty(
            petId: petId,
            logDate: date,
            dailyCalorieGoal: dailyCalorieGoal,
            dailyWaterGoalCups: dailyWaterGoalCups,
          );
    });
  }

  /// Loads (or returns an empty placeholder for) today's log.
  Future<PetCareLog> fetchTodayLog(
    String petId, {
    int dailyCalorieGoal = 500,
    int dailyWaterGoalCups = 8,
  }) async {
    final today = DateTime.now();
    final dateStr = _dateOnly(today);

    final raw = await supabase
        .from('pet_care_logs')
        .select()
        .eq('pet_id', petId)
        .eq('log_date', dateStr)
        .maybeSingle();

    if (raw == null) {
      return PetCareLog.empty(
        petId: petId,
        logDate: today,
        dailyCalorieGoal: dailyCalorieGoal,
        dailyWaterGoalCups: dailyWaterGoalCups,
      );
    }
    return PetCareLog.fromJson(raw);
  }

  /// Upserts a log row keyed on (pet_id, log_date).
  Future<PetCareLog> upsertLog(PetCareLog log) async {
    final data = await supabase
        .from('pet_care_logs')
        .upsert(log.toUpsertJson(), onConflict: 'pet_id,log_date')
        .select()
        .single();
    return PetCareLog.fromJson(data);
  }

  // ===========================================================================
  // WEIGHT LOGS
  // ===========================================================================

  Future<List<PetWeightLog>> fetchRecentWeights(
    String petId, {
    int days = 7,
  }) async {
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: days - 1));

    final raw = await supabase
        .from('pet_weight_logs')
        .select()
        .eq('pet_id', petId)
        .gte('log_date', _dateOnly(start))
        .order('log_date', ascending: true);

    return raw.map(PetWeightLog.fromJson).toList();
  }

  Future<PetWeightLog> upsertWeight(PetWeightLog log) async {
    final data = await supabase
        .from('pet_weight_logs')
        .upsert(log.toUpsertJson(), onConflict: 'pet_id,log_date')
        .select()
        .single();
    return PetWeightLog.fromJson(data);
  }

  // ===========================================================================
  // VET APPOINTMENTS
  // ===========================================================================

  Future<List<PetVetAppointment>> fetchAppointments(String petId) async {
    final raw = await supabase
        .from('pet_vet_appointments')
        .select()
        .eq('pet_id', petId)
        .order('scheduled_at', ascending: false);

    return raw.map(PetVetAppointment.fromJson).toList();
  }

  Future<List<PetVetAppointment>> fetchUpcomingAppointments(
    String petId,
  ) async {
    final raw = await supabase
        .from('pet_vet_appointments')
        .select()
        .eq('pet_id', petId)
        .gte('scheduled_at', DateTime.now().toUtc().toIso8601String())
        .order('scheduled_at', ascending: true);

    return raw.map(PetVetAppointment.fromJson).toList();
  }

  Future<PetVetAppointment> upsertAppointment(PetVetAppointment appt) async {
    final data = await supabase
        .from('pet_vet_appointments')
        .upsert(appt.toUpsertJson(), onConflict: 'id')
        .select()
        .single();
    return PetVetAppointment.fromJson(data);
  }

  Future<void> deleteAppointment(String id) async {
    await supabase.from('pet_vet_appointments').delete().eq('id', id);
  }

  // ===========================================================================
  // VACCINATIONS
  // ===========================================================================

  Future<List<PetVaccination>> fetchVaccinations(String petId) async {
    final raw = await supabase
        .from('pet_vaccinations')
        .select()
        .eq('pet_id', petId)
        .order('completed_on', ascending: false, nullsFirst: false)
        .order('scheduled_for', ascending: true, nullsFirst: false);

    return raw.map(PetVaccination.fromJson).toList();
  }

  Future<PetVaccination> upsertVaccination(PetVaccination vaccination) async {
    final data = await supabase
        .from('pet_vaccinations')
        .upsert(vaccination.toUpsertJson(), onConflict: 'id')
        .select()
        .single();
    return PetVaccination.fromJson(data);
  }

  Future<void> deleteVaccination(String id) async {
    await supabase.from('pet_vaccinations').delete().eq('id', id);
  }

  Future<PetVaccination> markVaccinationComplete(String id) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final data = await supabase
        .from('pet_vaccinations')
        .update({'status': 'completed', 'completed_on': today})
        .eq('id', id)
        .select()
        .single();
    return PetVaccination.fromJson(data);
  }

  // ===========================================================================
  // SYMPTOMS
  // ===========================================================================

  Future<List<PetSymptom>> fetchSymptoms(String petId) async {
    final raw = await supabase
        .from('pet_symptoms')
        .select()
        .eq('pet_id', petId)
        .order('resolved_at', ascending: false, nullsFirst: true)
        .order('observed_at', ascending: false);

    return raw.map(PetSymptom.fromJson).toList();
  }

  Future<PetSymptom> insertSymptom({
    required String petId,
    required String symptomType,
    required String severity,
    String? notes,
  }) async {
    final now = DateTime.now();
    final data = await supabase
        .from('pet_symptoms')
        .insert({
          'pet_id': petId,
          'observed_at': now.toUtc().toIso8601String(),
          'symptom_type': symptomType,
          'severity': severity,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        })
        .select()
        .single();
    return PetSymptom.fromJson(data);
  }

  Future<PetSymptom> resolveSymptom(String symptomId) async {
    final data = await supabase
        .from('pet_symptoms')
        .update({'resolved_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', symptomId)
        .select()
        .single();
    return PetSymptom.fromJson(data);
  }

  // ===========================================================================
  // helpers
  // ===========================================================================

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------------------
  // Onboarding (private table — owner only via RLS)
  // ---------------------------------------------------------------------------

  Future<PetCareOnboarding?> fetchOnboarding(String petId) async {
    final row = await supabase
        .from('pet_care_onboarding')
        .select()
        .eq('pet_id', petId)
        .maybeSingle();
    if (row == null) return null;
    return PetCareOnboarding.fromRow(row);
  }

  Future<void> saveOnboarding(
    String petId,
    Map<String, dynamic> data, {
    bool markComplete = false,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await fetchOnboarding(petId);
    final completed = markComplete ? now : existing?.completedAt;
    await supabase.from('pet_care_onboarding').upsert({
      'pet_id': petId,
      'data': data,
      if (completed != null) 'completed_at': completed.toIso8601String(),
    }, onConflict: 'pet_id');
  }

  // ---------------------------------------------------------------------------
  // Gamification & badges
  // ---------------------------------------------------------------------------

  Future<PetCareGamification?> fetchGamification(String petId) async {
    final row = await supabase
        .from('pet_care_gamification')
        .select()
        .eq('pet_id', petId)
        .maybeSingle();
    if (row == null) return null;
    return PetCareGamification.fromJson(row);
  }

  Future<PetCareGamification> upsertGamification(PetCareGamification g) async {
    final data = await supabase
        .from('pet_care_gamification')
        .upsert(g.toUpsertJson(), onConflict: 'pet_id')
        .select()
        .single();
    return PetCareGamification.fromJson(data);
  }

  Future<List<CareBadgeDefinition>> fetchBadgeDefinitions() async {
    final raw = await supabase
        .from('care_badge_definitions')
        .select()
        .order('sort_order', ascending: true);
    return raw.map(CareBadgeDefinition.fromJson).toList();
  }

  Future<List<PetCareBadgeUnlock>> fetchUnlocksForPet(String petId) async {
    final raw = await supabase
        .from('pet_care_badge_unlocks')
        .select('id, pet_id, badge_slug, unlocked_at')
        .eq('pet_id', petId)
        .order('unlocked_at', ascending: false);
    return raw.map(PetCareBadgeUnlock.fromJson).toList();
  }

  /// Inserts a row if missing. Ignores duplicate / permission errors.
  Future<void> insertUnlockIfNew({
    required String userId,
    required String petId,
    required String badgeSlug,
  }) async {
    final existing = await supabase
        .from('pet_care_badge_unlocks')
        .select('id')
        .eq('user_id', userId)
        .eq('pet_id', petId)
        .eq('badge_slug', badgeSlug)
        .maybeSingle();
    if (existing != null) return;
    await supabase.from('pet_care_badge_unlocks').insert({
      'user_id': userId,
      'pet_id': petId,
      'badge_slug': badgeSlug,
    });
  }

  /// Unlocks visible on public profile for [userId] (RLS allows showcase read).
  Future<List<PetCareBadgeUnlock>> fetchPublicShowcaseUnlocks(
    String userId,
  ) async {
    final p = await supabase
        .from('profiles')
        .select('public_care_badge_slugs, show_care_badges_on_profile')
        .eq('id', userId)
        .maybeSingle();
    if (p == null) return const [];
    if (p['show_care_badges_on_profile'] != true) return const [];
    final slugs = (p['public_care_badge_slugs'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
    if (slugs == null || slugs.isEmpty) return const [];

    final raw = await supabase
        .from('pet_care_badge_unlocks')
        .select('id, pet_id, badge_slug, unlocked_at')
        .eq('user_id', userId)
        .inFilter('badge_slug', slugs);
    return raw.map(PetCareBadgeUnlock.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Activity / Exercise Logs
  // ---------------------------------------------------------------------------

  Future<List<PetActivityLog>> fetchActivityLogs(
    String petId, {
    int days = 7,
  }) async {
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: days - 1));
    final raw = await supabase
        .from('pet_activity_logs')
        .select()
        .eq('pet_id', petId)
        .gte('log_date', _dateOnly(start))
        .order('log_date', ascending: false);
    return raw.map(PetActivityLog.fromJson).toList();
  }

  Future<PetActivityLog> insertActivityLog(PetActivityLog log) async {
    final data = await supabase
        .from('pet_activity_logs')
        .insert(log.toInsertJson())
        .select()
        .single();
    return PetActivityLog.fromJson(data);
  }
}

final petCareRepository = PetCareRepository();

final petCareRepositoryProvider = Provider<PetCareRepository>((ref) => petCareRepository);
