import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/feature_repositories.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';

final insuranceClaimsProvider = FutureProvider.autoDispose<List<InsuranceClaim>>((ref) async {
  final activePet = ref.watch(activePetProvider);
  if (activePet == null) return [];
  return insuranceClaimsRepository.fetchClaims(activePet.id);
});

class PetInsuranceController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> fileClaim({
    required String petId,
    required String title,
    required double amount,
    required DateTime incurredAt,
    String? notes,
  }) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await insuranceClaimsRepository.fileClaim(
        petId: petId,
        userId: userId,
        title: title,
        amount: amount,
        incurredAt: incurredAt,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(insuranceClaimsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final petInsuranceControllerProvider =
    NotifierProvider<PetInsuranceController, AsyncValue<void>>(() {
  return PetInsuranceController();
});
