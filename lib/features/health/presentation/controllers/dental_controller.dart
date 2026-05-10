import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petsphere/core/constants/app_strings.dart';
import 'package:petsphere/core/utils/logger.dart';
import 'package:petsphere/features/health/data/health_repository.dart';
import 'package:petsphere/features/health/data/models/pet_health_extended_models.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class DentalState {
  final List<DentalLog> logs;
  final bool isLoading;
  final String? error;

  const DentalState({
    this.logs = const [],
    this.isLoading = false,
    this.error,
  });

  DentalLog? get lastHomeBrushing {
    final matches =
        logs.where((d) => d.cleaningType == 'home_brushing').toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.logDate.compareTo(a.logDate));
    return matches.first;
  }

  DentalLog? get lastProfessionalCleaning {
    final matches =
        logs.where((d) => d.cleaningType == 'professional_cleaning').toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.logDate.compareTo(a.logDate));
    return matches.first;
  }

  DentalState copyWith({
    List<DentalLog>? logs,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => DentalState(
    logs: logs ?? this.logs,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class DentalNotifier extends Notifier<DentalState> {
  HealthRepository get _repo => ref.read(healthRepositoryProvider);

  @override
  DentalState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return DentalState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final logs = await _repo.fetchDentalLogs(petId);
      if (!ref.mounted) return;
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.healthLoadFailed,
      );
    }
  }

  Future<void> refresh() async {
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) await _load(petId);
  }

  Future<void> logDental(DentalLog entry) async {
    try {
      final saved = await _repo.logDental(entry);
      state = state.copyWith(logs: [saved, ...state.logs]);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthDentalLogFailed,
        tag: 'DentalNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthDentalLogFailed);
    }
  }

  Future<void> deleteDentalLog(String id) async {
    state = state.copyWith(
      logs: state.logs.where((d) => d.id != id).toList(),
    );
    try {
      await _repo.deleteDentalLog(id);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthDentalLogFailed,
        tag: 'DentalNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthDentalLogFailed);
      await refresh();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final dentalProvider = NotifierProvider<DentalNotifier, DentalState>(
  DentalNotifier.new,
);
