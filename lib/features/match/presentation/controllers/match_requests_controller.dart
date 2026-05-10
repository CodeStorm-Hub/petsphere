import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/match/data/models/match_request_model.dart';
import 'package:petfolio/features/match/data/match_repository.dart';
import 'package:petfolio/features/messaging/presentation/controllers/chat_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

@immutable
class MatchRequestsState {

  const MatchRequestsState({
    this.myRequests = const [],
    this.sentRequests = const [],
    this.isLoading = false,
    this.error,
  });
  final List<MatchRequestModel> myRequests;
  final List<MatchRequestModel> sentRequests;
  final bool isLoading;
  final String? error;

  MatchRequestsState copyWith({
    List<MatchRequestModel>? myRequests,
    List<MatchRequestModel>? sentRequests,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => MatchRequestsState(
    myRequests: myRequests ?? this.myRequests,
    sentRequests: sentRequests ?? this.sentRequests,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

class MatchRequestsNotifier extends Notifier<MatchRequestsState> {
  @override
  MatchRequestsState build() {
    final activePetId = ref.watch(activePetProvider.select((p) => p?.id));
    if (activePetId != null) {
      Future.microtask(() => _load(activePetId));
    }
    return MatchRequestsState(isLoading: activePetId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        matchRepository.fetchMyRequests(petId),
        matchRepository.fetchSentRequests(petId),
      ]);
      state = state.copyWith(
        myRequests: results[0],
        sentRequests: results[1],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) await _load(petId);
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

final matchRequestsProvider =
    NotifierProvider<MatchRequestsNotifier, MatchRequestsState>(
      MatchRequestsNotifier.new,
    );

final allMatchRequestsProvider = FutureProvider<List<MatchRequestModel>>((
  ref,
) async {
  final myPets = ref.watch(petProvider).myPets;
  if (myPets.isEmpty) return [];
  final petIds = myPets.map((p) => p.id).toList();
  return matchRepository.fetchAllMyRequests(petIds);
});
