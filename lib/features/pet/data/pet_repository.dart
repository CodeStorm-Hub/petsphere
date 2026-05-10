import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/core/constants/supabase_config.dart';

import 'package:petfolio/features/pet/data/models/pet_model.dart';

class PetRepository {
  // -------------------------------------------------------------------------
  // Fetch all pets (for discovery / feed)
  // -------------------------------------------------------------------------
  /// Bounded list for discovery/admin-style views — not every pet in the system at scale.
  Future<List<PetModel>> fetchAllPets({int limit = 500}) async {
    final data = await supabase
        .from('pets')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return data.map((e) => PetModel.fromJson(e)).toList();
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

    return data.map((e) => PetModel.fromJson(e)).toList();
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
    final json = pet.toJson()
      ..remove('id'); // Let Postgres generate the UUID via gen_random_uuid()
    final data = await supabase
        .from('pets')
        .insert(json)
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

  /// Upload a pet image to Supabase Storage — returns the public URL
  Future<String> uploadPetImage(String petId, File imageFile) async {
    final ext = imageFile.path.split('.').last;
    final path = '$petId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage.from(kBucketPetImages).upload(path, imageFile);

    return supabase.storage.from(kBucketPetImages).getPublicUrl(path);
  }

  // -------------------------------------------------------------------------
  // Delete a pet image from Supabase Storage (#45)
  // -------------------------------------------------------------------------

  /// Deletes a specific pet image by its [storagePath] (e.g. 'petId/12345.jpg').
  Future<void> deletePetImage(String storagePath) async {
    try {
      await supabase.storage.from(kBucketPetImages).remove([storagePath]);
    } catch (e) {
      log('deletePetImage failed for $storagePath: $e', name: 'PetRepository');
      rethrow;
    }
  }

  /// Extracts the storage path from a public bucket URL and deletes the object.
  /// Safe to call with non-storage URLs — will log and skip.
  Future<void> deletePhotoFromUrl(String publicUrl) async {
    try {
      final uri = Uri.parse(publicUrl);
      // Public URL format: .../storage/v1/object/public/<bucket>/<path>
      final segments = uri.pathSegments;
      final bucketIdx = segments.indexOf(kBucketPetImages);
      if (bucketIdx == -1 || bucketIdx + 1 >= segments.length) return;
      final storagePath = segments.sublist(bucketIdx + 1).join('/');
      await deletePetImage(storagePath);
    } catch (e) {
      log('deletePhotoFromUrl error for $publicUrl: $e', name: 'PetRepository');
    }
  }

  // -------------------------------------------------------------------------
  // Breed autocomplete (#46)
  // -------------------------------------------------------------------------

  /// Returns up to [limit] distinct breed strings matching [query].
  /// Queries the `pets` table for diversity across user-submitted breeds.
  Future<List<String>> fetchBreedSuggestions(
    String query, {
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) return [];
    try {
      final rows = await supabase
          .from('pets')
          .select('breed')
          .ilike('breed', '%${query.trim()}%')
          .not('breed', 'is', null)
          .limit(limit * 3); // over-fetch to dedup in Dart
      final seen = <String>{};
      final result = <String>[];
      for (final row in rows) {
        final breed = (row['breed'] as String?)?.trim();
        if (breed != null &&
            breed.isNotEmpty &&
            seen.add(breed.toLowerCase())) {
          result.add(breed);
          if (result.length >= limit) break;
        }
      }
      return result;
    } catch (e) {
      log('fetchBreedSuggestions error: $e', name: 'PetRepository');
      return [];
    }
  }
}

final petRepositoryProvider = Provider<PetRepository>((ref) => PetRepository());

final petRepository = PetRepository();

