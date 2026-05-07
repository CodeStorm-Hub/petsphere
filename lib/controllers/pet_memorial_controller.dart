import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_memorial_models.dart';
import '../repositories/feature_repositories.dart';

final memorialEntriesProvider = FutureProvider<List<PetMemorialEntry>>((ref) async {
  return ref.watch(petMemorialRepositoryProvider).fetchMemorials();
});

final memorialEntryProvider = FutureProvider.family<PetMemorialEntry?, String>((ref, id) async {
  return ref.watch(petMemorialRepositoryProvider).getMemorialEntryById(id);
});

final petMemorialRepositoryProvider = Provider((ref) => petMemorialRepository);

class PetMemorialController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createTribute(PetMemorialEntry entry) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(petMemorialRepositoryProvider).createMemorial(entry);
      ref.invalidate(memorialEntriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final petMemorialControllerProvider =
    NotifierProvider<PetMemorialController, AsyncValue<void>>(() {
  return PetMemorialController();
});
