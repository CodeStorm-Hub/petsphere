import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_request_model.dart';
import '../models/pet_model.dart';
import '../repositories/match_repository.dart';
import '../repositories/notification_repository.dart';
import 'auth_controller.dart';
import 'chat_controller.dart';
import 'pet_controller.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class MatchState {
  final List<PetModel> discoveryPets;
  final List<PetModel> _allDiscoveryPets; // unfiltered set for search
  final List<MatchRequestModel> myRequests;
  final List<MatchRequestModel> sentRequests;
  final bool isLoading;
  final String? filterAnimal;
  final String? filterBreed;
  final String searchQuery;
  final String? error;

  MatchState({
    this.discoveryPets = const [],
    List<PetModel>? allDiscoveryPets,
    this.myRequests = const [],
    this.sentRequests = const [],
    this.isLoading = false,
    this.filterAnimal,
    this.filterBreed,
    this.searchQuery = '',
    this.error,
  }) : _allDiscoveryPets = allDiscoveryPets ?? discoveryPets;

  List<PetModel> get allDiscoveryPets => _allDiscoveryPets;

  MatchState copyWith({
    List<PetModel>? discoveryPets,
    List<PetModel>? allDiscoveryPets,
    List<MatchRequestModel>? myRequests,
    List<MatchRequestModel>? sentRequests,
    bool? isLoading,
    String? filterAnimal,
    String? filterBreed,
    String? searchQuery,
    String? error,
    bool clearAnimal = false,
    bool clearBreed = false,
    bool clearError = false,
  }) {
    return MatchState(
      discoveryPets: discoveryPets ?? this.discoveryPets,
      allDiscoveryPets: allDiscoveryPets ?? _allDiscoveryPets,
      myRequests: myRequests ?? this.myRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      isLoading: isLoading ?? this.isLoading,
      filterAnimal: clearAnimal ? null : (filterAnimal ?? this.filterAnimal),
      filterBreed: clearBreed ? null : (filterBreed ?? this.filterBreed),
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class MatchController extends Notifier<MatchState> {
  int _loadGeneration = 0; // cancel stale async loads
  String? _lastLoadedPetId;

  @override
  MatchState build() {
    final activePet = ref.watch(activePetProvider);
    if (activePet == null) {
      _lastLoadedPetId = null;
      return MatchState();
    }

    // Do not return a fresh [MatchState(isLoading: true)] on every rebuild —
    // that wipes discovery data whenever [activePetProvider] notifies with the
    // same pet id (new model instance). Only reset loading when the pet id changes.
    if (_lastLoadedPetId != activePet.id) {
      _lastLoadedPetId = activePet.id;
      Future.microtask(() => _load(activePet.id));
      return MatchState(isLoading: true);
    }

    return state;
  }

  // When [silent] is true the loading flag is NOT set, so the UI avoids a
  // full-screen spinner. Use this for background refreshes (e.g. after a like).
  Future<void> _load(String myPetId, {bool silent = false}) async {
    final gen = ++_loadGeneration;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      if (!silent) state = state.copyWith(isLoading: false);
      return;
    }

    if (!silent) state = state.copyWith(isLoading: true, clearError: true);

    _currentDiscoveryPetId = myPetId;

    try {
      final futures = await Future.wait([
        matchRepository.fetchDiscoveryPets(
          myPetId: myPetId,
          userId: userId,
          filterAnimal: state.filterAnimal,
          filterBreed: state.filterBreed,
        ),
        matchRepository.fetchMyRequests(myPetId),
        matchRepository.fetchSentRequests(myPetId),
      ]);

      if (gen != _loadGeneration) return;

      final allPets = futures[0] as List<PetModel>;
      final filtered = _applySearchFilter(allPets, state.searchQuery);

      state = state.copyWith(
        discoveryPets: filtered,
        allDiscoveryPets: allPets,
        myRequests: futures[1] as List<MatchRequestModel>,
        sentRequests: futures[2] as List<MatchRequestModel>,
        isLoading: false,
      );
    } catch (e) {
      if (gen != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final activePet = ref.read(activePetProvider);
    if (activePet != null) {
      await _load(activePet.id);
    }
  }

  /// Loads discovery pets for [petId] directly, bypassing the global
  /// activePetProvider. Used by the per-tab pet selector on the discovery
  /// screen so the global active pet remains unchanged.
  Future<void> load(String petId) async => _load(petId);

  /// The pet ID that was most recently loaded into this controller.
  /// Tracks which pet the discovery screen is currently browsing for,
  /// even when it differs from the global [activePetProvider].
  String? get currentDiscoveryPetId => _currentDiscoveryPetId;
  String? _currentDiscoveryPetId;

  void setFilterBreed(String? breed) {
    final activePet = ref.read(activePetProvider);
    debugPrint(
        '[MatchController] setFilterBreed($breed) — activePet=${activePet?.name}');
    if (activePet == null) {
      debugPrint(
          '[MatchController] ⚠️ activePet is NULL — filter change ignored!');
      return;
    }
    if (breed == null || breed.isEmpty) {
      state = state.copyWith(clearBreed: true);
    } else {
      state = state.copyWith(filterBreed: breed);
    }
    debugPrint(
        '[MatchController] State updated: animal=${state.filterAnimal}, breed=${state.filterBreed}');
    _load(activePet.id);
  }

  void setFilterAnimal(String? animal) {
    final activePet = ref.read(activePetProvider);
    debugPrint(
        '[MatchController] setFilterAnimal($animal) — activePet=${activePet?.name}');
    if (activePet == null) {
      debugPrint(
          '[MatchController] ⚠️ activePet is NULL — filter change ignored!');
      return;
    }
    if (animal == null || animal.isEmpty) {
      state = state.copyWith(clearAnimal: true, clearBreed: true);
    } else {
      state = state.copyWith(filterAnimal: animal, clearBreed: true);
    }
    debugPrint(
        '[MatchController] State updated: animal=${state.filterAnimal}, breed=${state.filterBreed}');
    _load(activePet.id);
  }

  void setSearchQuery(String query) {
    final trimmed = query.trim().toLowerCase();
    final filtered = _applySearchFilter(state.allDiscoveryPets, trimmed);
    state = state.copyWith(
      searchQuery: trimmed,
      discoveryPets: filtered,
    );
  }

  List<PetModel> _applySearchFilter(List<PetModel> pets, String query) {
    if (query.isEmpty) return pets;
    return pets.where((pet) {
      return pet.name.toLowerCase().contains(query) ||
          pet.breed.toLowerCase().contains(query) ||
          pet.animalType.toLowerCase().contains(query);
    }).toList();
  }

  /// Send a like/match request from the currently-browsing pet to [receiverPetId].
  ///
  /// [fromPetId] should be the pet selected in the Discovery tab
  /// (from [discoveryActivePetIdProvider]). It defaults to the global
  /// [activePetProvider] only as a fallback.
  Future<bool> sendLikeRequest(
    String receiverPetId, {
    String? fromPetId,
  }) async {
    // Resolve the sender: prefer the explicitly passed discovery pet,
    // fall back to _currentDiscoveryPetId, then the global active pet.
    final myPets = ref.read(petProvider).myPets;
    final targetId = fromPetId ?? _currentDiscoveryPetId;
    PetModel? senderPet;
    if (targetId != null) {
      try {
        senderPet = myPets.firstWhere((p) => p.id == targetId);
      } catch (_) {
        senderPet = null;
      }
    }
    senderPet ??= ref.read(activePetProvider);
    if (senderPet == null) return false;

    // Prevent liking own pets
    final myPetIds = myPets.map((p) => p.id).toSet();
    if (myPetIds.contains(receiverPetId)) {
      state = state.copyWith(error: 'You cannot like your own pet.');
      return false;
    }

    // Capture receiver pet before removing it from state
    PetModel? receiverPet;
    for (final p in state.allDiscoveryPets) {
      if (p.id == receiverPetId) {
        receiverPet = p;
        break;
      }
    }

    try {
      await matchRepository.sendLikeRequest(
        senderPetId: senderPet.id,
        receiverPetId: receiverPetId,
      );

      // Optimistically remove the liked pet from the in-memory list.
      final discoveryPets =
          state.discoveryPets.where((p) => p.id != receiverPetId).toList();
      final allDiscoveryPets =
          state.allDiscoveryPets.where((p) => p.id != receiverPetId).toList();
      state = state.copyWith(
        discoveryPets: discoveryPets,
        allDiscoveryPets: allDiscoveryPets,
      );

      // Notify the receiver pet's owner
      if (receiverPet != null && receiverPet.userId.isNotEmpty) {
        notificationRepository.sendNotification(
          targetUserId: receiverPet.userId,
          title: 'New breeding interest',
          body:
              '${senderPet.name} is interested in breeding with ${receiverPet.name}.',
          type: 'match_request',
          entityType: 'match_request',
          entityId: senderPet.id,
          actorPetId: senderPet.id,
        );
      }

      // Silent background refresh for the correct (discovery-selected) pet —
      // does NOT show a loading spinner, so the UI transition is seamless.
      _load(senderPet.id, silent: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Could not send request: $e');
      return false;
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

      // Match accepted notifications are handled by the DB trigger
      // (notify_on_match_accepted) to avoid duplicates.

      // A DB trigger creates the chat_threads row — refresh thread list so
      // the new thread immediately appears in the inbox.
      await ref.read(chatProvider.notifier).refresh();
    } catch (e) {
      state = state.copyWith(error: 'Could not accept request: $e');
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      await matchRepository.updateRequestStatus(requestId, 'rejected');
      state = state.copyWith(
        myRequests:
            state.myRequests.where((req) => req.id != requestId).toList(),
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

/// Aggregated incoming match requests for ALL of the current user's pets.
/// Used by the Notifications screen so the Requests tab always shows the
/// full picture regardless of which pet is selected in the Discovery tab.
final allMatchRequestsProvider =
    FutureProvider<List<MatchRequestModel>>((ref) async {
  final myPets = ref.watch(petProvider).myPets;
  if (myPets.isEmpty) return [];
  final petIds = myPets.map((p) => p.id).toList();
  return matchRepository.fetchAllMyRequests(petIds);
});
