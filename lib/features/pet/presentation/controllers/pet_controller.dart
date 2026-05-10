import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/core/constants/app_strings.dart';
import 'package:petfolio/core/utils/logger.dart';

import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/pet/data/pet_repository.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class PetState {

  PetState({
    this.myPets = const [],
    this.activePet,
    this.isLoading = false,
    this.error,
  });
  final List<PetModel> myPets;
  final PetModel? activePet; // The "currently acting as" pet
  final bool isLoading;
  final String? error;

  PetState copyWith({
    List<PetModel>? myPets,
    PetModel? activePet,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PetState(
      myPets: myPets ?? this.myPets,
      activePet: activePet ?? this.activePet,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasNoPets => myPets.isEmpty && !isLoading;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class PetNotifier extends Notifier<PetState> {
  String? _lastLoadedUserId;
  int _loadGeneration = 0;

  @override
  PetState build() {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        if (_lastLoadedUserId != next.user!.id) {
          _loadMyPets(next.user!.id);
        }
      } else if (next.status == AuthStatus.unauthenticated) {
        _lastLoadedUserId = null;
        _loadGeneration++;
        state = PetState();
      }
    });

    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      Future.microtask(() => _loadMyPets(authState.user!.id));
    }

    return PetState(isLoading: true);
  }

  Future<void> _loadMyPets(String userId) async {
    _lastLoadedUserId = userId;
    final gen = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pets = await ref.read(petRepositoryProvider).fetchMyPets(userId);
      if (gen != _loadGeneration) return;
      state = state.copyWith(
        myPets: pets,
        activePet: pets.isNotEmpty ? pets.first : null,
        isLoading: false,
      );
    } catch (e) {
      if (gen != _loadGeneration) return;
      AppLogger.error(AppStrings.petLoadFailed, tag: 'PetNotifier', error: e);
      state = state.copyWith(isLoading: false, error: AppStrings.petLoadFailed);
    }
  }

  /// Reload pets (call after creating a new pet)
  Future<void> reload() async {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      await _loadMyPets(authState.user!.id);
    }
  }

  /// Create a new pet with optional profile image upload
  Future<bool> createPet({
    required String name,
    required String breed,
    required String animalType,
    required int age,
    required String bio,
    String profileImageUrl = '',
  }) async {
    final authState = ref.read(authProvider);
    final userId = authState.user?.id;
    if (userId == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newPet = PetModel(
        id: '', // Will be set by DB
        userId: userId,
        name: name,
        breed: breed,
        animalType: animalType,
        age: age,
        bio: bio,
        profileImageUrl: profileImageUrl,
      );

      final created = await ref.read(petRepositoryProvider).createPet(newPet);
      final updatedPets = <PetModel>[created, ...state.myPets];

      state = state.copyWith(
        myPets: updatedPets,
        activePet: state.activePet ?? created,
        isLoading: false,
      );
      AppLogger.info(
        'Pet created successfully: ${created.name}',
        tag: 'PetNotifier',
      );
      return true;
    } catch (e) {
      AppLogger.error(AppStrings.petCreateFailed, tag: 'PetNotifier', error: e);
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.petCreateFailed,
      );
      return false;
    }
  }

  Future<bool> updatePet(String petId, Map<String, dynamic> fields) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedPet = await ref.read(petRepositoryProvider).updatePet(petId, fields);
      state = state.copyWith(
        myPets: _replacePetInList(petId, updatedPet),
        activePet: state.activePet?.id == petId ? updatedPet : state.activePet,
        isLoading: false,
      );
      AppLogger.info('Pet updated successfully', tag: 'PetNotifier');
      return true;
    } catch (e) {
      AppLogger.error(AppStrings.petUpdateFailed, tag: 'PetNotifier', error: e);
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.petUpdateFailed,
      );
      return false;
    }
  }

  Future<bool> toggleBreedingListing(String petId, bool isListed) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedPet = await ref.read(petRepositoryProvider).updatePet(petId, {
        'is_breeding_listed': isListed,
      });

      state = state.copyWith(
        myPets: _replacePetInList(petId, updatedPet),
        activePet: state.activePet?.id == petId ? updatedPet : state.activePet,
        isLoading: false,
      );
      AppLogger.info(
        'Breeding listing toggled to: $isListed',
        tag: 'PetNotifier',
      );
      return true;
    } catch (e) {
      AppLogger.error(AppStrings.petUpdateFailed, tag: 'PetNotifier', error: e);
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.petUpdateFailed,
      );
      return false;
    }
  }

  void setActivePet(PetModel pet) {
    state = state.copyWith(activePet: pet);
  }

  // ── Photo management (#45) ────────────────────────────────────────────────

  /// Removes [photoUrl] from storage and clears it from the pet record.
  Future<bool> removePhoto(String petId, String photoUrl) async {
    try {
      // Delete from Supabase Storage first; ignore if not a storage URL.
      await ref.read(petRepositoryProvider).deletePhotoFromUrl(photoUrl);
      // Clear the profileImageUrl on the DB row if it matches.
      final pet = _findPetById(petId) ?? state.activePet;
      if (pet == null) {
        state = state.copyWith(error: AppStrings.petLoadFailed);
        return false;
      }
      if (pet.profileImageUrl == photoUrl) {
        return updatePet(petId, {'profile_image_url': null});
      }
      return true;
    } catch (e) {
      AppLogger.error(
        AppStrings.petImageUploadFailed,
        tag: 'PetNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.petImageUploadFailed);
      return false;
    }
  }

  List<PetModel> _replacePetInList(String petId, PetModel updatedPet) {
    return state.myPets
        .map((pet) => pet.id == petId ? updatedPet : pet)
        .toList();
  }

  PetModel? _findPetById(String petId) {
    for (final pet in state.myPets) {
      if (pet.id == petId) return pet;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final petProvider = NotifierProvider<PetNotifier, PetState>(() {
  return PetNotifier();
});

/// Convenience provider to get just the active pet
final activePetProvider = Provider<PetModel?>((ref) {
  return ref.watch(petProvider).activePet;
});

/// Triggers navigation to a specific pet's profile tab.
/// Set the pet ID via `ref.read(...notifier).navigateTo(petId)`,
/// then reset after handling.
class ProfilePetNavigation extends Notifier<String?> {
  @override
  String? build() => null;

  void navigateTo(String petId) => state = petId;
  void clear() => state = null;
}

final profilePetNavigationProvider =
    NotifierProvider<ProfilePetNavigation, String?>(
      () => ProfilePetNavigation(),
    );

/// [MainLayout] listens and switches its bottom tab to the requested index
/// (e.g. 4 for Profile), then clears the value.
class MainLayoutTabRequest extends Notifier<int?> {
  @override
  int? build() => null;

  void request(int index) => state = index;

  void clear() => state = null;
}

final mainLayoutTabRequestProvider =
    NotifierProvider<MainLayoutTabRequest, int?>(MainLayoutTabRequest.new);

/// Breed autocomplete provider (#46).
/// Usage: ref.watch(breedSuggestionsProvider('retriev'))
final breedSuggestionsProvider = FutureProvider.family<List<String>, String>((
  ref,
  query,
) async {
  if (query.trim().length < 2) return [];
  return ref.watch(petRepositoryProvider).fetchBreedSuggestions(query.trim());
});
