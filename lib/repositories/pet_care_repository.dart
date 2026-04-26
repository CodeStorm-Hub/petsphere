import '../models/pet_care_log_model.dart';
import '../models/pet_health_models.dart';
import '../utils/supabase_config.dart';

export '../models/pet_health_models.dart' show PetSymptom;

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
    final startDate = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    final startStr = _dateOnly(startDate);

    final raw = await supabase
        .from('pet_care_logs')
        .select()
        .eq('pet_id', petId)
        .gte('log_date', startStr)
        .order('log_date', ascending: false);

    final byDate = <String, PetCareLog>{
      for (final row in (raw as List).cast<Map<String, dynamic>>())
        row['log_date'] as String: PetCareLog.fromJson(row),
    };

    return List.generate(days, (i) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
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
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));

    final raw = await supabase
        .from('pet_weight_logs')
        .select()
        .eq('pet_id', petId)
        .gte('log_date', _dateOnly(start))
        .order('log_date', ascending: true);

    return (raw as List)
        .cast<Map<String, dynamic>>()
        .map(PetWeightLog.fromJson)
        .toList();
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

  Future<List<PetVetAppointment>> fetchUpcomingAppointments(String petId) async {
    final raw = await supabase
        .from('pet_vet_appointments')
        .select()
        .eq('pet_id', petId)
        .gte('scheduled_at', DateTime.now().toUtc().toIso8601String())
        .order('scheduled_at', ascending: true);

    return (raw as List)
        .cast<Map<String, dynamic>>()
        .map(PetVetAppointment.fromJson)
        .toList();
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

    return (raw as List)
        .cast<Map<String, dynamic>>()
        .map(PetVaccination.fromJson)
        .toList();
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

    return (raw as List)
        .cast<Map<String, dynamic>>()
        .map(PetSymptom.fromJson)
        .toList();
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
}

final petCareRepository = PetCareRepository();
