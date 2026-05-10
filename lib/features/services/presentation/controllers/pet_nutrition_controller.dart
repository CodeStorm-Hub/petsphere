import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petsphere/features/health/data/nutrition_repository.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';

final todayNutritionProvider = FutureProvider.autoDispose<List<NutritionLog>>((
  ref,
) async {
  final activePet = ref.watch(activePetProvider);
  if (activePet == null) return [];
  return nutritionRepository.fetchTodayLogs(activePet.id);
});

class PetNutritionController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> addMeal({
    required String petId,
    required String mealName,
    required String mealType,
    int? calories,
    int? proteinPct,
    int? fatPct,
    int? carbPct,
    int? waterMl,
  }) async {
    state = const AsyncValue.loading();
    try {
      await nutritionRepository.addLog(
        NutritionLog(
          id: '', // Will be generated
          petId: petId,
          mealName: mealName,
          mealType: mealType,
          calories: calories,
          proteinPct: proteinPct,
          fatPct: fatPct,
          carbPct: carbPct,
          waterMl: waterMl,
          loggedAt: DateTime.now(),
        ),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(todayNutritionProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteLog(String id) async {
    state = const AsyncValue.loading();
    try {
      await nutritionRepository.deleteLog(id);
      state = const AsyncValue.data(null);
      ref.invalidate(todayNutritionProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final petNutritionControllerProvider =
    NotifierProvider<PetNutritionController, AsyncValue<void>>(() {
      return PetNutritionController();
    });
