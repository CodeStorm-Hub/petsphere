import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/social/data/follow_repository.dart';
import 'package:petfolio/features/match/data/match_repository.dart';
import 'package:petfolio/features/notifications/data/notification_repository.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

class DiscoveryPetIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? petId) => state = petId;
}

final discoveryActivePetIdProvider =
    NotifierProvider<DiscoveryPetIdNotifier, String?>(
      DiscoveryPetIdNotifier.new,
    );

@immutable
class MatchDiscoveryState {

  const MatchDiscoveryState({
    this.discoveryPets = const [],
    this.allDiscoveryPets = const [],
    this.discoveryFollowerCounts = const {},
    this.isLoading = false,
    this.filterAnimal,
    this.filterBreed,
    this.searchQuery = '',
    this.error,
  });
  final List<PetModel> discoveryPets;
  final List<PetModel> allDiscoveryPets;
  final Map<String, int> discoveryFollowerCounts;
  final bool isLoading;
  final String? filterAnimal;
  final String? filterBreed;
  final String searchQuery;
  final String? error;

  MatchDiscoveryState copyWith({
    List<PetModel>? discoveryPets,
    List<PetModel>? allDiscoveryPets,
    Map<String, int>? discoveryFollowerCounts,
    bool? isLoading,
    String? filterAnimal,
    String? filterBreed,
    String? searchQuery,
    String? error,
    bool clearAnimal = false,
    bool clearBreed = false,
    bool clearError = false,
  }) => MatchDiscoveryState(
    discoveryPets: discoveryPets ?? this.discoveryPets,
    allDiscoveryPets: allDiscoveryPets ?? this.allDiscoveryPets,
    discoveryFollowerCounts:
        discoveryFollowerCounts ?? this.discoveryFollowerCounts,
    isLoading: isLoading ?? this.isLoading,
    filterAnimal: clearAnimal ? null : (filterAnimal ?? this.filterAnimal),
    filterBreed: clearBreed ? null : (filterBreed ?? this.filterBreed),
    searchQuery: searchQuery ?? this.searchQuery,
    error: clearError ? null : (error ?? this.error),
  );
}

class MatchDiscoveryNotifier extends Notifier<MatchDiscoveryState> {
  int _loadGeneration = 0;
  String? _lastLoadedPetId;

  @override
  MatchDiscoveryState build() {
    final activePet = ref.watch(activePetProvider);
    final myPets = ref.watch(petProvider.select((s) => s.myPets));

    if (myPets.isEmpty) {
      _lastLoadedPetId = null;
      return const MatchDiscoveryState();
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
      _lastLoadedPetId = targetId;
      Future.microtask(() => load(targetId!));
      return MatchDiscoveryState(
        isLoading: true,
        filterAnimal: state.filterAnimal,
        filterBreed: state.filterBreed,
        searchQuery: state.searchQuery,
      );
    }

    return state;
  }

  Future<void> load(String myPetId, {bool silent = false}) async {
    final gen = ++_loadGeneration;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    if (!silent) state = state.copyWith(isLoading: true, clearError: true);

    final myPets = ref.read(petProvider).myPets;
    final viewerPet = myPets.cast<PetModel?>().firstWhere(
      (p) => p?.id == myPetId,
      orElse: () => null,
    );
    final viewerAnimalType = viewerPet?.animalType.trim();

    try {
      final allPets = await matchRepository.fetchDiscoveryPets(
        myPetId: myPetId,
        userId: userId,
        allMyPetIds: myPets.map((p) => p.id).toList(),
        filterBreed: state.filterBreed,
        viewerAnimalType: (viewerAnimalType?.isNotEmpty ?? false)
            ? viewerAnimalType
            : null,
      );

      if (gen != _loadGeneration) return;

      final filtered = _applySearchFilter(allPets, state.searchQuery);
      var followerCounts = <String, int>{};

      if (allPets.isNotEmpty) {
        try {
          followerCounts = await followRepository.fetchPetFollowerCounts(
            allPets.map((p) => p.id),
          );
        } catch (e) {
          debugPrint('Follower counts batch skipped: $e');
        }
      }

      if (gen != _loadGeneration) return;

      state = state.copyWith(
        discoveryPets: filtered,
        allDiscoveryPets: allPets,
        discoveryFollowerCounts: followerCounts,
        isLoading: false,
      );
    } catch (e) {
      if (gen != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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

  Future<void> refresh() async {
    if (_lastLoadedPetId != null) await load(_lastLoadedPetId!);
  }

  Future<bool> sendLikeRequest(
    String receiverPetId, {
    String? fromPetId,
  }) async {
    final myPets = ref.read(petProvider).myPets;
    final targetId = fromPetId ?? _lastLoadedPetId;

    var senderPet = myPets.cast<PetModel?>().firstWhere(
      (p) => p?.id == targetId,
      orElse: () => null,
    );
    senderPet ??= ref.read(activePetProvider);
    if (senderPet == null) return false;

    if (myPets.any((p) => p.id == receiverPetId)) {
      state = state.copyWith(error: 'You cannot like your own pet.');
      return false;
    }

    final receiverPet = state.allDiscoveryPets.cast<PetModel?>().firstWhere(
      (p) => p?.id == receiverPetId,
      orElse: () => null,
    );

    try {
      final matchRequestId = await matchRepository.sendLikeRequest(
        senderPetId: senderPet.id,
        receiverPetId: receiverPetId,
      );

      state = state.copyWith(
        discoveryPets: state.discoveryPets
            .where((p) => p.id != receiverPetId)
            .toList(),
        allDiscoveryPets: state.allDiscoveryPets
            .where((p) => p.id != receiverPetId)
            .toList(),
        discoveryFollowerCounts: Map.from(state.discoveryFollowerCounts)
          ..remove(receiverPetId),
      );

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

      unawaited(load(senderPet.id, silent: true));
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void setFilterBreed(String? breed) {
    if (breed == null || breed.isEmpty) {
      state = state.copyWith(clearBreed: true);
    } else {
      state = state.copyWith(filterBreed: breed);
    }
    if (_lastLoadedPetId != null) load(_lastLoadedPetId!);
  }

  void setFilterAnimal(String? animal) {
    if (animal == null || animal.isEmpty) {
      state = state.copyWith(clearAnimal: true, clearBreed: true);
    } else {
      state = state.copyWith(filterAnimal: animal, clearBreed: true);
    }
    if (_lastLoadedPetId != null) load(_lastLoadedPetId!);
  }
}

final matchDiscoveryProvider =
    NotifierProvider<MatchDiscoveryNotifier, MatchDiscoveryState>(
      MatchDiscoveryNotifier.new,
    );
