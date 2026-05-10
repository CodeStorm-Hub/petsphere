import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petsphere/features/care/data/models/pet_activity_log_model.dart';
import 'package:petsphere/features/care/data/pet_care_repository.dart';
import 'package:petsphere/features/health/data/models/pet_health_models.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';

@immutable
class VitalsState {
  final List<PetWeightLog> weightLogs;
  final List<PetActivityLog> activityLogs;
  final bool isLoading;
  final String? error;
  final String? activePetId;

  const VitalsState({
    this.weightLogs = const [],
    this.activityLogs = const [],
    this.isLoading = false,
    this.error,
    this.activePetId,
  });

  PetWeightLog? get latestWeight =>
      weightLogs.isNotEmpty ? weightLogs.first : null;

  double get averageActivityDuration {
    if (activityLogs.isEmpty) return 0;
    final total = activityLogs.fold<int>(
      0,
      (sum, log) => sum + log.durationMinutes,
    );
    return total / activityLogs.length;
  }

  VitalsState copyWith({
    List<PetWeightLog>? weightLogs,
    List<PetActivityLog>? activityLogs,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? activePetId,
  }) => VitalsState(
    weightLogs: weightLogs ?? this.weightLogs,
    activityLogs: activityLogs ?? this.activityLogs,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    activePetId: activePetId ?? this.activePetId,
  );
}

class VitalsNotifier extends Notifier<VitalsState> {
  final _repo = petCareRepository;

  @override
  VitalsState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return VitalsState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      activePetId: petId,
    );
    try {
      final results = await Future.wait([
        _repo.fetchRecentWeights(petId, days: 30),
        _repo.fetchActivityLogs(petId),
      ]);
      if (!ref.mounted) return;
      state = state.copyWith(
        weightLogs: results[0] as List<PetWeightLog>,
        activityLogs: results[1] as List<PetActivityLog>,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final id = state.activePetId;
    if (id != null) await _load(id);
  }

  Future<void> addWeightLog(double weight, DateTime date) async {
    final petId = state.activePetId;
    if (petId == null) return;

    final log = PetWeightLog(
      id: '',
      petId: petId,
      weightLbs: weight,
      logDate: date,
    );

    try {
      final saved = await _repo.upsertWeight(log);
      state = state.copyWith(
        weightLogs: [saved, ...state.weightLogs]
          ..sort((a, b) => b.logDate.compareTo(a.logDate)),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addActivityLog(PetActivityLog log) async {
    try {
      final saved = await _repo.insertActivityLog(log);
      state = state.copyWith(
        activityLogs: [saved, ...state.activityLogs]
          ..sort((a, b) => b.logDate.compareTo(a.logDate)),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> logWeight({
    required double weight,
    int? bcsScore,
    String? notes,
    DateTime? date,
  }) async {
    final petId = state.activePetId;
    if (petId == null) return;

    final log = PetWeightLog(
      petId: petId,
      weightLbs: weight,
      logDate: date ?? DateTime.now(),
      bcsScore: bcsScore,
      notes: notes,
    );

    try {
      final saved = await _repo.upsertWeight(log);
      state = state.copyWith(
        weightLogs: [saved, ...state.weightLogs]
          ..sort((a, b) => b.logDate.compareTo(a.logDate)),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final vitalsProvider = NotifierProvider<VitalsNotifier, VitalsState>(
  VitalsNotifier.new,
);
