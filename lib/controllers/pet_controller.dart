import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../repositories/pet_repository.dart';
import 'auth_controller.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class PetState {
  final List<PetModel> myPets;
  final PetModel? activePet; // The "currently acting as" pet
  final bool isLoading;
  final String? error;

  PetState({
    this.myPets = const [],
    this.activePet,
    this.isLoading = false,
    this.error,
  });

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
  @override
  PetState build() {
    // Watch auth state — reload pets when user changes
    final authState = ref.watch(authProvider);
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      _loadMyPets(authState.user!.id);
    }
    return PetState();
  }

  Future<void> _loadMyPets(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pets = await petRepository.fetchMyPets(userId);
      state = state.copyWith(
        myPets: pets,
        activePet: pets.isNotEmpty ? pets.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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

      final created = await petRepository.createPet(newPet);
      final updatedPets = [created, ...state.myPets];

      state = state.copyWith(
        myPets: updatedPets,
        activePet: state.activePet ?? created,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePet(String petId, Map<String, dynamic> fields) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedPet = await petRepository.updatePet(petId, fields);
      final updatedList = state.myPets.map((p) {
        return p.id == petId ? updatedPet : p;
      }).toList();

      state = state.copyWith(
        myPets: updatedList,
        activePet: state.activePet?.id == petId ? updatedPet : state.activePet,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void setActivePet(PetModel pet) {
    state = state.copyWith(activePet: pet);
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
    NotifierProvider<ProfilePetNavigation, String?>(() => ProfilePetNavigation());
