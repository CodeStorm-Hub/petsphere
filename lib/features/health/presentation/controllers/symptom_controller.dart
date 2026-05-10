import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petsphere/features/care/data/pet_care_repository.dart';

import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';

@immutable
class SymptomState {
  final List<PetSymptom> symptoms;
  final bool isLoading;
  final String? error;
  final String? activePetId;

  const SymptomState({
    this.symptoms = const [],
    this.isLoading = false,
    this.error,
    this.activePetId,
  });

  List<PetSymptom> get activeSymptoms =>
      symptoms.where((s) => !s.isResolved).toList();

  List<PetSymptom> get resolvedSymptoms =>
      symptoms.where((s) => s.isResolved).toList();

  SymptomState copyWith({
    List<PetSymptom>? symptoms,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? activePetId,
  }) => SymptomState(
    symptoms: symptoms ?? this.symptoms,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    activePetId: activePetId ?? this.activePetId,
  );
}

class SymptomNotifier extends Notifier<SymptomState> {
  final _repo = petCareRepository;

  @override
  SymptomState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return SymptomState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      activePetId: petId,
    );
    try {
      final symptoms = await _repo.fetchSymptoms(petId);
      if (!ref.mounted) return;
      state = state.copyWith(
        symptoms: symptoms,
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

  Future<void> addSymptom({
    required String type,
    required String severity,
    String? notes,
  }) async {
    final petId = state.activePetId;
    if (petId == null) return;

    try {
      final newSymptom = await _repo.insertSymptom(
        petId: petId,
        symptomType: type,
        severity: severity,
        notes: notes,
      );
      state = state.copyWith(
        symptoms: [newSymptom, ...state.symptoms],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resolveSymptom(String symptomId) async {
    try {
      final updated = await _repo.resolveSymptom(symptomId);
      state = state.copyWith(
        symptoms: state.symptoms.map((s) => s.id == symptomId ? updated : s).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final symptomProvider = NotifierProvider<SymptomNotifier, SymptomState>(SymptomNotifier.new);
