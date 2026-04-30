import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet_care_log_model.dart';
import '../models/pet_health_models.dart';

/// Lightweight SharedPreferences-backed cache for the Pet Care feature.
///
/// Why SharedPreferences and not a full local DB?
///
/// The care screen only needs "show something while re-fetching" — the data
/// is small (a handful of recent logs), staleness is always corrected by a
/// live Supabase fetch, and the user base targets mobile, not power-offline
/// scenarios. SharedPreferences handles this perfectly without the schema
/// overhead of drift/sqflite.
///
/// Cache keys are namespaced per-pet to avoid cross-pet pollution.
class CareCache {
  static const _prefix = 'care_cache_v1';

  // ─────────────────────────────────────────────────────────────────────────
  // Care logs (today + recent week)
  // ─────────────────────────────────────────────────────────────────────────
  static String _logsKey(String petId) => '${_prefix}_logs_$petId';

  static Future<void> saveLogs(
    String petId,
    List<PetCareLog> logs,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(logs.map((l) => l.toUpsertJson()).toList());
    await prefs.setString(_logsKey(petId), encoded);
  }

  static Future<List<PetCareLog>> loadLogs(
    String petId, {
    int dailyCalorieGoal = 500,
    int dailyWaterGoalCups = 8,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_logsKey(petId));
      if (raw == null) return [];
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list
          .map((json) {
            try {
              return PetCareLog.fromJson({
                ...json,
                'pet_id': json['pet_id'] ?? petId,
              });
            } catch (_) {
              return null;
            }
          })
          .whereType<PetCareLog>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Weight logs
  // ─────────────────────────────────────────────────────────────────────────
  static String _weightsKey(String petId) => '${_prefix}_weights_$petId';

  static Future<void> saveWeights(
    String petId,
    List<PetWeightLog> weights,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      weights.map((w) => w.toUpsertJson()).toList(),
    );
    await prefs.setString(_weightsKey(petId), encoded);
  }

  static Future<List<PetWeightLog>> loadWeights(String petId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_weightsKey(petId));
      if (raw == null) return [];
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list
          .map((json) {
            try {
              return PetWeightLog.fromJson({
                ...json,
                'pet_id': json['pet_id'] ?? petId,
              });
            } catch (_) {
              return null;
            }
          })
          .whereType<PetWeightLog>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clear (e.g. on sign-out)
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> clearForPet(String petId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logsKey(petId));
    await prefs.remove(_weightsKey(petId));
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
