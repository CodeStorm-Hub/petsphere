import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/core/constants/app_strings.dart';
import 'package:petfolio/core/utils/logger.dart';

import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/match/data/match_repository.dart';
import 'package:petfolio/features/match/data/models/match_request_model.dart';
import 'package:petfolio/features/messaging/presentation/controllers/chat_controller.dart';
import 'package:petfolio/features/notifications/data/notification_repository.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/social/data/follow_repository.dart';

// ---------------------------------------------------------------------------
// Discovery tab: which of the user's pets is browsing (null = active pet)
// ---------------------------------------------------------------------------

class DiscoveryPetIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? petId) => state = petId;
}

final discoveryActivePetIdProvider =
    NotifierProvider<DiscoveryPetIdNotifier, String?>(
      DiscoveryPetIdNotifier.new,
    );

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class MatchState {

  MatchState({
    this.discoveryPets = const [],
    List<PetModel>? allDiscoveryPets,
    this.myRequests = const [],
    this.sentRequests = const [],
    this.discoveryFollowerCounts = const {},
    this.isLoading = false,
    this.filterAnimal,
    this.filterBreed,
    this.searchQuery = '',
    this.error,
  }) : _allDiscoveryPets = allDiscoveryPets ?? discoveryPets;
  final List<PetModel> discoveryPets;
  final List<PetModel> _allDiscoveryPets; // unfiltered set for search
  final List<MatchRequestModel> myRequests;
  final List<MatchRequestModel> sentRequests;

  /// Batched follower counts for pets on the discovery feed (Issue #29).
  final Map<String, int> discoveryFollowerCounts;
  final bool isLoading;
  final String? filterAnimal;
  final String? filterBreed;
  final String searchQuery;
  final String? error;

  List<PetModel> get allDiscoveryPets => _allDiscoveryPets;

  MatchState copyWith({
    List<PetModel>? discoveryPets,
    List<PetModel>? allDiscoveryPets,
    List<MatchRequestModel>? myRequests,
    List<MatchRequestModel>? sentRequests,
    Map<String, int>? discoveryFollowerCounts,
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
      discoveryFollowerCounts:
          discoveryFollowerCounts ?? this.discoveryFollowerCounts,
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
    final myPets = ref.watch(petProvider.select((s) => s.myPets));

    if (myPets.isEmpty) {
      _lastLoadedPetId = null;
      Future.microtask(
        () => ref.read(discoveryActivePetIdProvider.notifier).select(null),
      );
      return MatchState();
    }

    final browsingId = ref.watch(discoveryActivePetIdProvider);
    var targetId = browsingId ?? activePet?.id;
    if (targetId != null && !myPets.any((p) => p.id == targetId)) {
      targetId = activePet?.id ?? myPets.first.id;
      Future.microtask(
        () => ref.read(discoveryActivePetIdProvider.notifier).select(targetId),
      );
    }
    targetId ??= activePet?.id ?? myPets.first.id;

    if (_lastLoadedPetId != targetId) {
      final hadPriorLoad = _lastLoadedPetId != null;
      _lastLoadedPetId = targetId;
      Future.microtask(() => _load(targetId!));
      if (!hadPriorLoad) {
        return MatchState(isLoading: true);
      }
      return MatchState(
        isLoading: true,
        filterAnimal: state.filterAnimal,
        filterBreed: state.filterBreed,
        searchQuery: state.searchQuery,
        discoveryFollowerCounts: state.discoveryFollowerCounts,
        allDiscoveryPets: const [],
        myRequests: state.myRequests,
        sentRequests: state.sentRequests,
      );
    }

    return state;
  }

  String? _resolveDiscoveryTargetPetId() {
    return ref.read(discoveryActivePetIdProvider) ??
        ref.read(activePetProvider)?.id;
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

    final myPets = ref.read(petProvider).myPets;
    PetModel? viewerPet;
    for (final p in myPets) {
      if (p.id == myPetId) {
        viewerPet = p;
        break;
      }
    }
    final viewerAnimalType = viewerPet?.animalType.trim();

    try {
      final futures = await Future.wait([
        matchRepository.fetchDiscoveryPets(
          myPetId: myPetId,
          userId: userId,
          allMyPetIds: myPets.map((p) => p.id).toList(),
          filterBreed: state.filterBreed,
          viewerAnimalType:
              (viewerAnimalType != null && viewerAnimalType.isNotEmpty)
              ? viewerAnimalType
              : null,
        ),
        matchRepository.fetchMyRequests(myPetId),
        matchRepository.fetchSentRequests(myPetId),
      ]);

      if (gen != _loadGeneration) return;

      final allPets = futures[0] as List<PetModel>;
      final filtered = _applySearchFilter(allPets, state.searchQuery);

      var followerCounts = <String, int>{};
      try {
        if (allPets.isNotEmpty) {
          followerCounts = await followRepository.fetchPetFollowerCounts(
            allPets.map((p) => p.id),
          );
        }
      } catch (e) {
        AppLogger.debug(
          'Follower counts batch skipped',
          tag: 'MatchController',
        );
      }

      if (gen != _loadGeneration) return;

      state = state.copyWith(
        discoveryPets: filtered,
        allDiscoveryPets: allPets,
        myRequests: futures[1] as List<MatchRequestModel>,
        sentRequests: futures[2] as List<MatchRequestModel>,
        discoveryFollowerCounts: followerCounts,
        isLoading: false,
      );
    } catch (e) {
      if (gen != _loadGeneration) return;
      AppLogger.error(
        AppStrings.matchLoadFailed,
        tag: 'MatchController',
        error: e,
      );
      state = state.copyWith(isLoading: false, error: AppStrings.matchLoadFailed);
    }
  }

  Future<void> refresh() async {
    final target = _resolveDiscoveryTargetPetId();
    if (target != null) {
      await _load(target);
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
    final target = _resolveDiscoveryTargetPetId();
    AppLogger.debug(
      'setFilterBreed($breed) — targetPetId=$target',
      tag: 'MatchController',
    );
    if (target == null) {
      AppLogger.debug(
        'No discovery target pet — filter change ignored',
        tag: 'MatchController',
      );
      return;
    }
    if (breed == null || breed.isEmpty) {
      state = state.copyWith(clearBreed: true);
    } else {
      state = state.copyWith(filterBreed: breed);
    }
    AppLogger.debug(
      'State updated: animal=${state.filterAnimal}, breed=${state.filterBreed}',
      tag: 'MatchController',
    );
    _load(target);
  }

  void setFilterAnimal(String? animal) {
    final target = _resolveDiscoveryTargetPetId();
    AppLogger.debug(
      'setFilterAnimal($animal) — targetPetId=$target',
      tag: 'MatchController',
    );
    if (target == null) {
      AppLogger.debug(
        'No discovery target pet — filter change ignored',
        tag: 'MatchController',
      );
      return;
    }
    if (animal == null || animal.isEmpty) {
      state = state.copyWith(clearAnimal: true, clearBreed: true);
    } else {
      state = state.copyWith(filterAnimal: animal, clearBreed: true);
    }
    AppLogger.debug(
      'State updated: animal=${state.filterAnimal}, breed=${state.filterBreed}',
      tag: 'MatchController',
    );
    _load(target);
  }

  void setSearchQuery(String query) {
    final trimmed = query.trim().toLowerCase();
    final filtered = _applySearchFilter(state.allDiscoveryPets, trimmed);
    state = state.copyWith(searchQuery: trimmed, discoveryPets: filtered);
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
      state = state.copyWith(error: AppStrings.matchOwnPetError);
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
      final matchRequestId = await matchRepository.sendLikeRequest(
        senderPetId: senderPet.id,
        receiverPetId: receiverPetId,
      );

      // Optimistically remove the liked pet from the in-memory list.
      final discoveryPets = state.discoveryPets
          .where((p) => p.id != receiverPetId)
          .toList();
      final allDiscoveryPets = state.allDiscoveryPets
          .where((p) => p.id != receiverPetId)
          .toList();
      state = state.copyWith(
        discoveryPets: discoveryPets,
        allDiscoveryPets: allDiscoveryPets,
        discoveryFollowerCounts: {
          for (final e in state.discoveryFollowerCounts.entries)
            if (e.key != receiverPetId) e.key: e.value,
        },
      );

      // Notify the receiver pet's owner
      if (receiverPet != null && receiverPet.userId.isNotEmpty) {
        unawaited(notificationRepository.sendNotification(
          targetUserId: receiverPet.userId,
          title: 'New breeding interest',
          body:
              '${senderPet.name} is interested in breeding with ${receiverPet.name}.',
          type: 'match_request',
          entityType: 'match_request',
          entityId: matchRequestId,
          actorPetId: senderPet.id,
        ));
      }

      // Silent background refresh for the correct (discovery-selected) pet —
      // does NOT show a loading spinner, so the UI transition is seamless.
      unawaited(_load(senderPet.id, silent: true));
      return true;
    } on StateError catch (e) {
      if (e.message == 'duplicate_match_request') {
        AppLogger.warning(
          AppStrings.matchDuplicateRequestError,
          tag: 'MatchController',
        );
        state = state.copyWith(
          error: AppStrings.matchDuplicateRequestError,
        );
      } else {
        AppLogger.error(
          AppStrings.matchRequestSendFailed,
          tag: 'MatchController',
          error: e,
        );
        state = state.copyWith(error: AppStrings.matchRequestSendFailed);
      }
      return false;
    } catch (e) {
      AppLogger.error(
        AppStrings.matchRequestSendFailed,
        tag: 'MatchController',
        error: e,
      );
      state = state.copyWith(error: AppStrings.matchRequestSendFailed);
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

/// Aggregated incoming match requests for ALL of the current user's pets.
/// Used by the Notifications screen so the Requests tab always shows the
/// full picture regardless of which pet is selected in the Discovery tab.
final allMatchRequestsProvider = FutureProvider<List<MatchRequestModel>>((
  ref,
) async {
  final myPets = ref.watch(petProvider).myPets;
  if (myPets.isEmpty) return [];
  final petIds = myPets.map((p) => p.id).toList();
  return matchRepository.fetchAllMyRequests(petIds);
});
