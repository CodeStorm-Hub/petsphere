import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';
import '../utils/supabase_config.dart';

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
    await _ensureProfileExists(pet.userId);

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

  Future<void> _ensureProfileExists(String userId) async {
    final authUser = supabase.auth.currentUser;
    final metadataName = authUser?.userMetadata?['name'] as String?;
    final resolvedName =
        (metadataName != null && metadataName.trim().isNotEmpty)
        ? metadataName.trim()
        : (authUser?.email?.split('@').first ?? 'Pet Lover');

    try {
      await supabase.from('profiles').insert({
        'id': userId,
        'name': resolvedName,
      });
    } on PostgrestException catch (e) {
      // Duplicate key means profile already exists — safe to ignore.
      if (e.code == '23505') return;
      rethrow;
    }
  }
}

final petRepository = PetRepository();
