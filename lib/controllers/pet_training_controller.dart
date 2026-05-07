import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/feature_repositories.dart';
import '../controllers/pet_controller.dart';

final petTrainingProgressProvider =
    FutureProvider.autoDispose<List<TrainingProgress>>((ref) async {
  final activePet = ref.watch(activePetProvider);
  if (activePet == null) return [];
  return trainingRepository.fetchProgress(activePet.id);
});

class PetTrainingController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> logSession({
    required String petId,
    required String command,
    required bool mastered,
    String? notes,
    String? programId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await trainingRepository.logCommand(
        petId: petId,
        command: command,
        mastered: mastered,
        notes: notes,
        programId: programId,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(petTrainingProgressProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteProgress(String petId, String command) async {
    state = const AsyncValue.loading();
    try {
      await trainingRepository.deleteProgress(petId, command);
      state = const AsyncValue.data(null);
      ref.invalidate(petTrainingProgressProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final petTrainingControllerProvider =
    NotifierProvider<PetTrainingController, AsyncValue<void>>(() {
  return PetTrainingController();
});
