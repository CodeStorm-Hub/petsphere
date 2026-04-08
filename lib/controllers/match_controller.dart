import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_request_model.dart';
import '../models/pet_model.dart';
import '../repositories/match_repository.dart';
import 'auth_controller.dart';
import 'pet_controller.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class MatchState {
  final List<PetModel> discoveryPets;
  final List<MatchRequestModel> myRequests;
  final bool isLoading;
  final String? filterAnimal;
  final String? filterBreed;
  final String? error;

  MatchState({
    this.discoveryPets = const [],
    this.myRequests = const [],
    this.isLoading = false,
    this.filterAnimal,
    this.filterBreed,
    this.error,
  });

  MatchState copyWith({
    List<PetModel>? discoveryPets,
    List<MatchRequestModel>? myRequests,
    bool? isLoading,
    String? filterAnimal,
    String? filterBreed,
    String? error,
    bool clearAnimal = false,
    bool clearBreed = false,
    bool clearError = false,
  }) {
    return MatchState(
      discoveryPets: discoveryPets ?? this.discoveryPets,
      myRequests: myRequests ?? this.myRequests,
      isLoading: isLoading ?? this.isLoading,
      filterAnimal: clearAnimal ? null : (filterAnimal ?? this.filterAnimal),
      filterBreed: clearBreed ? null : (filterBreed ?? this.filterBreed),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class MatchController extends Notifier<MatchState> {
  int _loadGeneration = 0; // cancel stale async loads

  @override
  MatchState build() {
    final activePet = ref.watch(activePetProvider);
    if (activePet != null) {
      // Defer async state mutations until after initial state is returned.
      Future.microtask(() => _load(activePet.id));
      return MatchState(isLoading: true);
    }
    return MatchState();
  }

  /// Always reads filters from the current state, never from parameters.
  /// Uses a generation counter so stale fetches don't overwrite newer state.
  Future<void> _load(String myPetId) async {
    final gen = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final futures = await Future.wait([
        matchRepository.fetchDiscoveryPets(
          myPetId: myPetId,
          filterAnimal: state.filterAnimal,
          filterBreed: state.filterBreed,
        ),
        matchRepository.fetchMyRequests(myPetId),
      ]);

      // Only apply results if this is still the latest load
      if (gen != _loadGeneration) return;

      state = state.copyWith(
        discoveryPets: futures[0] as List<PetModel>,
        myRequests: futures[1] as List<MatchRequestModel>,
        isLoading: false,
      );
    } catch (e) {
      if (gen != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilterBreed(String? breed) {
    final activePet = ref.read(activePetProvider);
    debugPrint(
      '[MatchController] setFilterBreed($breed) — activePet=${activePet?.name}',
    );
    if (activePet == null) {
      debugPrint(
        '[MatchController] ⚠️ activePet is NULL — filter change ignored!',
      );
      return;
    }
    if (breed == null || breed.isEmpty) {
      state = state.copyWith(clearBreed: true);
    } else {
      state = state.copyWith(filterBreed: breed);
    }
    debugPrint(
      '[MatchController] State updated: animal=${state.filterAnimal}, breed=${state.filterBreed}',
    );
    _load(activePet.id);
  }

  void setFilterAnimal(String? animal) {
    final activePet = ref.read(activePetProvider);
    debugPrint(
      '[MatchController] setFilterAnimal($animal) — activePet=${activePet?.name}',
    );
    if (activePet == null) {
      debugPrint(
        '[MatchController] ⚠️ activePet is NULL — filter change ignored!',
      );
      return;
    }
    if (animal == null || animal.isEmpty) {
      state = state.copyWith(clearAnimal: true, clearBreed: true);
    } else {
      state = state.copyWith(filterAnimal: animal, clearBreed: true);
    }
    debugPrint(
      '[MatchController] State updated: animal=${state.filterAnimal}, breed=${state.filterBreed}',
    );
    _load(activePet.id);
  }

  Future<void> sendLikeRequest(String receiverPetId) async {
    final activePet = ref.read(activePetProvider);
    if (activePet == null) return;
    try {
      await matchRepository.sendLikeRequest(
        senderPetId: activePet.id,
        receiverPetId: receiverPetId,
      );
      // Remove from discovery list optimistically
      state = state.copyWith(
        discoveryPets: state.discoveryPets
            .where((p) => p.id != receiverPetId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Could not send request: $e');
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await matchRepository.updateRequestStatus(requestId, 'matched');
      state = state.copyWith(
        myRequests: state.myRequests.map((req) {
          if (req.id == requestId) return req.copyWith(status: 'matched');
          return req;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Could not accept request: $e');
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      await matchRepository.updateRequestStatus(requestId, 'rejected');
      state = state.copyWith(
        myRequests: state.myRequests
            .where((req) => req.id != requestId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Could not decline request: $e');
    }
  }

  Future<bool> listPetForDiscovery(String petId) async {
    final userId = ref.read(authProvider).user?.id;
    final activePet = ref.read(activePetProvider);
    if (userId == null) {
      state = state.copyWith(error: 'Please sign in again.');
      return false;
    }

    try {
      await matchRepository.listPetForDiscovery(
        petId: petId,
        listedByUserId: userId,
      );

      if (activePet != null) {
        await _load(activePet.id);
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Could not list pet: $e');
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final matchProvider = NotifierProvider<MatchController, MatchState>(() {
  return MatchController();
});
