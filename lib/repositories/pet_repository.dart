import 'dart:io';
import '../models/pet_model.dart';
import '../utils/supabase_config.dart';

final RegExp _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
);

class PetRepository {
  // -------------------------------------------------------------------------
  // Fetch all pets (for discovery / feed)
  // -------------------------------------------------------------------------
  Future<List<PetModel>> fetchAllPets() async {
    final data = await supabase
        .from('pets')
        .select()
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => PetModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Fetch pets belonging to a specific user
  // -------------------------------------------------------------------------
  Future<List<PetModel>> fetchMyPets(String userId) async {
    final data = await supabase
        .from('pets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return (data as List<dynamic>)
        .map((e) => PetModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Fetch a single pet by id
  // -------------------------------------------------------------------------
  Future<PetModel?> fetchPetById(String petId) async {
    // Prevent invalid UUID requests (which produce avoidable 400 responses).
    if (!_uuidPattern.hasMatch(petId)) return null;

    final data = await supabase
        .from('pets')
        .select()
        .eq('id', petId)
        .maybeSingle();

    if (data == null) return null;
    return PetModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Create a new pet
  // -------------------------------------------------------------------------
  Future<PetModel> createPet(PetModel pet) async {
    final data = await supabase
        .from('pets')
        .insert(pet.toJson())
        .select()
        .single();

    return PetModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Update pet fields
  // -------------------------------------------------------------------------
  Future<PetModel> updatePet(String petId, Map<String, dynamic> fields) async {
    final data = await supabase
        .from('pets')
        .update(fields)
        .eq('id', petId)
        .select()
        .single();

    return PetModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Upload a pet image to Supabase Storage — returns the public URL
  // -------------------------------------------------------------------------
  Future<String> uploadPetImage(String petId, File imageFile) async {
    final ext = imageFile.path.split('.').last;
    final path = '$petId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage.from(kBucketPetImages).upload(path, imageFile);

    return supabase.storage.from(kBucketPetImages).getPublicUrl(path);
  }
}

final petRepository = PetRepository();
