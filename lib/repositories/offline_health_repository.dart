import 'package:pet_dating_app/models/pet_health_extended_models.dart';
import 'package:pet_dating_app/repositories/health_repository.dart';
import 'package:pet_dating_app/utils/connectivity_service.dart';
import 'package:pet_dating_app/utils/offline_cache.dart';

/// Offline-first wrapper around HealthRepository.
///
/// Strategy:
/// - Fetch operations: Cache with 6-hour TTL, fallback to cache when offline
/// - Write operations (logging doses, etc): Queue if offline
class OfflineHealthRepository {
  final HealthRepository _repository;
  final OfflineCache _cache;
  final ConnectivityService _connectivity;

  static const Duration _healthDataCacheTTL = Duration(hours: 6);

  OfflineHealthRepository({
    required HealthRepository repository,
    required OfflineCache cache,
    required ConnectivityService connectivity,
  })  : _repository = repository,
        _cache = cache,
        _connectivity = connectivity;

  /// Fetch medications for a pet
  Future<List<PetMedication>> fetchMedications(String petId) async {
    if (_connectivity.isOffline) {
      final cached = _cache.getCachedPetHealth(petId);
      if (cached != null && cached.containsKey('medications')) {
        final meds = cached['medications'] as List;
        return meds.map((m) => PetMedication.fromJson(m)).toList();
      }
      throw Exception('No cached medications for offline access');
    }

    // Online - check cache first
    if (_cache.isPetHealthFresh(petId, _healthDataCacheTTL)) {
      final cached = _cache.getCachedPetHealth(petId);
      if (cached != null && cached.containsKey('medications')) {
        final meds = cached['medications'] as List;
        return meds.map((m) => PetMedication.fromJson(m)).toList();
      }
    }

    // Cache stale - fetch from network
    try {
      final medications = await _repository.fetchMedications(petId);

      // Cache medications
      final cached = _cache.getCachedPetHealth(petId) ?? {};
      cached['medications'] =
          medications.map((m) => m.toUpsertJson()).toList();
      await _cache.cachePetHealth(petId, cached);

      return medications;
    } catch (e) {
      // Fallback to cache
      final cached = _cache.getCachedPetHealth(petId);
      if (cached != null && cached.containsKey('medications')) {
        final meds = cached['medications'] as List;
        return meds.map((m) => PetMedication.fromJson(m)).toList();
      }
      rethrow;
    }
  }

  /// Log a medication dose - queued if offline
  Future<MedicationDose?> logDose(MedicationDose dose) async {
    if (_connectivity.isOffline) {
      await _cache.queueSyncOperation(
        operation: 'create',
        table: 'pet_medication_doses',
        data: {
          'id': dose.id,
          'medication_id': dose.medicationId,
          'pet_id': dose.petId,
          'scheduled_for': dose.scheduledFor.toIso8601String(),
          'given_at': dose.givenAt?.toIso8601String(),
          'skipped': dose.skipped,
          'notes': dose.notes,
        },
      );
      return null; // Queued
    }

    // Online - log immediately
    try {
      final result = await _repository.logDose(dose);
      // Invalidate cache since medications changed
      await _cache.clearCache('offline_pet_health_${dose.petId}');
      return result;
    } catch (e) {
      // Queue for sync on error
      await _cache.queueSyncOperation(
        operation: 'create',
        table: 'pet_medication_doses',
        data: {
          'id': dose.id,
          'medication_id': dose.medicationId,
          'pet_id': dose.petId,
          'scheduled_for': dose.scheduledFor.toIso8601String(),
          'given_at': dose.givenAt?.toIso8601String(),
          'skipped': dose.skipped,
          'notes': dose.notes,
        },
      );
      return null;
    }
  }

  /// Mark a dose as given - queued if offline
  Future<MedicationDose?> markDoseGiven(MedicationDose dose) async {
    if (_connectivity.isOffline) {
      await _cache.queueSyncOperation(
        operation: 'update',
        table: 'pet_medication_doses',
        data: {
          'id': dose.id,
          'given_at': DateTime.now().toIso8601String(),
        },
      );
      return null;
    }

    try {
      final result = await _repository.markDoseGiven(dose);
      await _cache.clearCache('offline_pet_health_${dose.petId}');
      return result;
    } catch (e) {
      await _cache.queueSyncOperation(
        operation: 'update',
        table: 'pet_medication_doses',
        data: {
          'id': dose.id,
          'given_at': DateTime.now().toIso8601String(),
        },
      );
      return null;
    }
  }

  /// Clear health cache for a pet
  Future<void> clearCache(String petId) async {
    await _cache.clearCache('offline_pet_health_$petId');
  }
}
