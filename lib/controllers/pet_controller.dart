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
    final userId = authState.user?.id;
    if (authState.status == AuthStatus.authenticated && userId != null) {
      // Defer async state mutations until after initial state is returned.
      Future.microtask(() => _loadMyPets(userId));
      return PetState(isLoading: true);
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
