import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/services/data/sitter_repository.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';

final mySitterJobsProvider = FutureProvider.autoDispose<List<SitterJob>>((
  ref,
) async {
  return sitterJobsRepository.fetchMyJobs();
});

final openSitterJobsProvider = FutureProvider.autoDispose<List<SitterJob>>((
  ref,
) async {
  return sitterJobsRepository.fetchOpenJobs();
});

class PetSitterController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> postJob({
    required String? petId,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    double? ratePerDay,
  }) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await sitterJobsRepository.postJob(
        petOwnerId: userId,
        petId: petId,
        startDate: startDate,
        endDate: endDate,
        description: description,
        ratePerDay: ratePerDay,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(mySitterJobsProvider);
      ref.invalidate(openSitterJobsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final petSitterControllerProvider =
    NotifierProvider<PetSitterController, AsyncValue<void>>(
      PetSitterController.new,
    );
