import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_request_model.dart';
import '../models/pet_model.dart';
import 'feed_controller.dart'; // To access mockPets

class MatchState {
  final List<PetModel> discoveryPets;
  final List<MatchRequestModel> myRequests; // Requests received by me
  final String? filterBreed;
  
  MatchState({
    this.discoveryPets = const [],
    this.myRequests = const [],
    this.filterBreed,
  });

  MatchState copyWith({
    List<PetModel>? discoveryPets,
    List<MatchRequestModel>? myRequests,
    String? filterBreed,
  }) {
    return MatchState(
      discoveryPets: discoveryPets ?? this.discoveryPets,
      myRequests: myRequests ?? this.myRequests,
      filterBreed: filterBreed ?? this.filterBreed,
    );
  }
}

class MatchController extends Notifier<MatchState> {
  @override
  MatchState build() {
    // Current pet is mockPets[0] (Bella). Don't show Bella to herself.
    final available = mockPets.where((pet) => pet.id != 'pet-1').toList();
    
    // Add mock request for testing UI (Luna liked Bella)
    final initialRequests = [
      MatchRequestModel(
        id: 'mr-1',
        senderPetId: 'pet-3', // Luna
        receiverPetId: 'pet-1', // Bella
        createdAt: DateTime.now(),
        senderPet: mockPets[2],
      )
    ];

    return MatchState(discoveryPets: available, myRequests: initialRequests);
  }

  void setFilterBreed(String? breed) {
    var available = mockPets.where((pet) => pet.id != 'pet-1').toList();
    if (breed != null && breed.isNotEmpty) {
      available = available.where((p) => p.breed == breed).toList();
    }
    state = state.copyWith(discoveryPets: available, filterBreed: breed);
  }

  void sendLikeRequest(String receiverPetId) {
    // Real app: Send this to backend
    // For mock: We only see state for ourselves so no need to update receiver's list
    // Maybe show a snackbar in the UI.
  }

  void acceptRequest(String requestId) {
    state = state.copyWith(
      myRequests: state.myRequests.map((req) {
        if (req.id == requestId) {
          return req.copyWith(status: 'matched');
        }
        return req;
      }).toList(),
    );
  }
  
  void declineRequest(String requestId) {
    state = state.copyWith(
      myRequests: state.myRequests.map((req) {
        if (req.id == requestId) {
          return req.copyWith(status: 'rejected');
        }
        return req;
      }).toList(),
    );
  }
}

final matchProvider = NotifierProvider<MatchController, MatchState>(() {
  return MatchController();
});
