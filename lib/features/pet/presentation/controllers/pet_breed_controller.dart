import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petsphere/features/pet/data/breed_repository.dart';

class PetBreedController extends Notifier<AsyncValue<BreedScan?>> {
  @override
  AsyncValue<BreedScan?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> identifyBreed(String imagePath) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(breedIdentifierRepositoryProvider);
      final result = await repository.identifyBreed(imagePath);
      state = AsyncValue.data(result);

      // Save to history
      await repository.saveScan(result);

      // Refresh history provider
      ref.invalidate(breedScanHistoryProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final breedIdentifierRepositoryProvider = Provider(
  (ref) => breedIdentifierRepository,
);

final breedIdentifierControllerProvider =
    NotifierProvider<PetBreedController, AsyncValue<BreedScan?>>(() {
      return PetBreedController();
    });

final breedScanHistoryProvider = FutureProvider<List<BreedScan>>((ref) async {
  final repository = ref.watch(breedIdentifierRepositoryProvider);
  return repository.fetchScanHistory();
});
