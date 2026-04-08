import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_request_model.dart';
import '../models/pet_model.dart';
import '../repositories/match_repository.dart';
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
  @override
  MatchState build() {
    // Watch active pet — reload discovery & requests when it changes
    final activePet = ref.watch(activePetProvider);
    if (activePet != null) {
      _load(activePet.id);
    }
    return MatchState(isLoading: true);
  }

  Future<void> _load(String myPetId, {String? animal, String? breed}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final futures = await Future.wait([
        matchRepository.fetchDiscoveryPets(
          myPetId: myPetId,
          filterAnimal: animal,
          filterBreed: breed,
        ),
        matchRepository.fetchMyRequests(myPetId),
      ]);

      state = state.copyWith(
        discoveryPets: futures[0] as List<PetModel>,
        myRequests: futures[1] as List<MatchRequestModel>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilterBreed(String? breed) {
    final activePet = ref.read(activePetProvider);
    if (activePet == null) return;
    _load(activePet.id,
        animal: state.filterAnimal, breed: breed == '' ? null : breed);
  }

  void setFilterAnimal(String? animal) {
    final activePet = ref.read(activePetProvider);
    if (activePet == null) return;
    _load(activePet.id, animal: animal == '' ? null : animal);
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
        discoveryPets:
            state.discoveryPets.where((p) => p.id != receiverPetId).toList(),
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
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final matchProvider = NotifierProvider<MatchController, MatchState>(() {
  return MatchController();
});
