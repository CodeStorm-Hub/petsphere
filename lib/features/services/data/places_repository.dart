import 'package:petsphere/core/constants/supabase_config.dart';
import 'package:petsphere/features/services/data/models/pet_friendly_place_model.dart';

class PetFriendlyPlacesRepository {
  Future<List<PetFriendlyPlace>> fetchPetFriendlyPlaces(String category) async {
    final response = await supabase
        .from('pet_friendly_places')
        .select()
        .eq('category', category)
        .order('distance_miles')
        .limit(30);

    return (response as List)
        .cast<Map<String, dynamic>>()
        .map(PetFriendlyPlace.fromJson)
        .toList();
  }
}

final petFriendlyPlacesRepository = PetFriendlyPlacesRepository();
