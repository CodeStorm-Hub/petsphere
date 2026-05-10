import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/services/data/models/pet_friendly_place_model.dart';
import 'package:petfolio/features/services/data/places_repository.dart';

class PetFriendlyPlaceCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Parks';
  void set(String category) => state = category;
}

final petFriendlyPlaceCategoryProvider =
    NotifierProvider<PetFriendlyPlaceCategoryNotifier, String>(() {
  return PetFriendlyPlaceCategoryNotifier();
});

final petFriendlyPlacesProvider = FutureProvider<List<PetFriendlyPlace>>((ref) async {
  final category = ref.watch(petFriendlyPlaceCategoryProvider);
  return petFriendlyPlacesRepository.fetchPetFriendlyPlaces(category);
});
