import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';
import '../utils/supabase_config.dart';

class PetRepository {
  static const int _maxPetAge = 50;
  static const int _maxNameLength = 80;
  static const int _maxBreedLength = 80;
  static const int _maxBioLength = 500;
  static const Set<String> _allowedAnimalTypes = {
    'Dog',
    'Cat',
    'Bird',
    'Rabbit',
    'Fish',
    'Other',
  };

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
    final normalizedName = pet.name.trim();
    final normalizedBreed = pet.breed.trim();
    final normalizedBio = pet.bio.trim();
    final normalizedAnimalType = pet.animalType.trim();
    final normalizedProfileImageUrl = pet.profileImageUrl.trim();

    _validateName(normalizedName);
    _validateBreed(normalizedBreed);
    _validateAge(pet.age);
    _validateAnimalType(normalizedAnimalType);
    _validateBio(normalizedBio);

    await _ensureProfileExists(pet.userId);

    final payload = {
      ...pet.toJson(),
      'name': normalizedName,
      'breed': normalizedBreed,
      'animal_type': normalizedAnimalType,
      'bio': normalizedBio,
      'profile_image_url': normalizedProfileImageUrl,
    };

    final data = await supabase.from('pets').insert(payload).select().single();

    return PetModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Update pet fields
  // -------------------------------------------------------------------------
  Future<PetModel> updatePet(String petId, Map<String, dynamic> fields) async {
    final sanitizedFields = _sanitizeAndValidateUpdateFields(fields);

    final data = await supabase
        .from('pets')
        .update(sanitizedFields)
        .eq('id', petId)
        .select()
        .single();

    return PetModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Upload a pet image to Supabase Storage — returns the public URL
  // -------------------------------------------------------------------------
  Future<String> uploadPetImage(
    String petId,
    Uint8List imageBytes, {
    String extension = 'jpg',
  }) async {
    final ext = extension;
    final path = '$petId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage
        .from(kBucketPetImages)
        .uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from(kBucketPetImages).getPublicUrl(path);
  }

  Future<void> _ensureProfileExists(String userId) async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null || authUser.id != userId) {
      throw StateError(
        'Cannot ensure profile for unauthenticated or mismatched user.',
      );
    }

    final metadataName = authUser.userMetadata?['name'];
    final trimmedMetadataName = metadataName?.toString().trim();
    final resolvedName =
        (trimmedMetadataName != null && trimmedMetadataName.isNotEmpty)
        ? trimmedMetadataName
        : (authUser.email?.split('@').first ?? 'Pet Lover');

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

  Map<String, dynamic> _sanitizeAndValidateUpdateFields(
    Map<String, dynamic> fields,
  ) {
    final sanitized = Map<String, dynamic>.from(fields);

    if (sanitized.containsKey('name')) {
      final name = sanitized['name']?.toString().trim() ?? '';
      _validateName(name);
      sanitized['name'] = name;
    }

    if (sanitized.containsKey('breed')) {
      final breed = sanitized['breed']?.toString().trim() ?? '';
      _validateBreed(breed);
      sanitized['breed'] = breed;
    }

    if (sanitized.containsKey('bio')) {
      final bio = sanitized['bio']?.toString().trim() ?? '';
      _validateBio(bio);
      sanitized['bio'] = bio;
    }

    if (sanitized.containsKey('animal_type')) {
      final animalType = sanitized['animal_type']?.toString().trim() ?? '';
      _validateAnimalType(animalType);
      sanitized['animal_type'] = animalType;
    }

    if (sanitized.containsKey('age')) {
      final rawAge = sanitized['age'];
      final age = rawAge is int ? rawAge : int.tryParse(rawAge.toString());
      if (age == null) {
        throw ArgumentError('Pet age must be a valid integer.');
      }
      _validateAge(age);
      sanitized['age'] = age;
    }

    if (sanitized.containsKey('profile_image_url')) {
      sanitized['profile_image_url'] =
          sanitized['profile_image_url']?.toString().trim() ?? '';
    }

    return sanitized;
  }

  void _validateName(String name) {
    if (name.isEmpty || name.length > _maxNameLength) {
      throw ArgumentError(
        'Pet name is required and must be at most $_maxNameLength characters.',
      );
    }
  }

  void _validateBreed(String breed) {
    if (breed.isEmpty || breed.length > _maxBreedLength) {
      throw ArgumentError(
        'Pet breed is required and must be at most $_maxBreedLength characters.',
      );
    }
  }

  void _validateBio(String bio) {
    if (bio.length > _maxBioLength) {
      throw ArgumentError('Pet bio must be at most $_maxBioLength characters.');
    }
  }

  void _validateAge(int age) {
    if (age <= 0 || age > _maxPetAge) {
      throw ArgumentError('Pet age must be between 1 and $_maxPetAge.');
    }
  }

  void _validateAnimalType(String animalType) {
    if (!_allowedAnimalTypes.contains(animalType)) {
      throw ArgumentError('Pet animal type is not supported.');
    }
  }
}

final petRepository = PetRepository();
