import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/core/constants/app_strings.dart';
import 'package:petfolio/core/utils/logger.dart';
import 'package:petfolio/features/health/data/health_repository.dart';
import 'package:petfolio/features/health/data/models/pet_health_extended_models.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ParasiteState {
  final List<ParasitePrevention> entries;
  final bool isLoading;
  final String? error;

  const ParasiteState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  List<ParasitePrevention> get overdue =>
      entries.where((p) => p.isOverdue).toList();

  /// Latest treatment per product type (for the summary cards).
  List<ParasitePrevention> get latestPerType {
    final seen = <String>{};
    final result = <ParasitePrevention>[];
    for (final p in entries) {
      if (!seen.contains(p.productType)) {
        seen.add(p.productType);
        result.add(p);
      }
    }
    return result;
  }

  ParasiteState copyWith({
    List<ParasitePrevention>? entries,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => ParasiteState(
    entries: entries ?? this.entries,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ParasiteNotifier extends Notifier<ParasiteState> {
  HealthRepository get _repo => ref.read(healthRepositoryProvider);

  @override
  ParasiteState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return ParasiteState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final entries = await _repo.fetchParasitePrevention(petId);
      if (!ref.mounted) return;
      state = state.copyWith(entries: entries, isLoading: false);
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

  Future<void> logTreatment(ParasitePrevention entry) async {
    try {
      final saved = await _repo.logParasiteTreatment(entry);
      state = state.copyWith(entries: [saved, ...state.entries]);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthParasiteLogFailed,
        tag: 'ParasiteNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthParasiteLogFailed);
    }
  }

  Future<void> deleteEntry(String id) async {
    state = state.copyWith(
      entries: state.entries.where((p) => p.id != id).toList(),
    );
    try {
      await _repo.deleteParasiteEntry(id);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthParasiteDeleteFailed,
        tag: 'ParasiteNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthParasiteDeleteFailed);
      await refresh();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final parasiteProvider = NotifierProvider<ParasiteNotifier, ParasiteState>(
  ParasiteNotifier.new,
);
