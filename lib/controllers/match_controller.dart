import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_request_model.dart';
import '../models/pet_model.dart';
import 'feed_controller.dart'; // To access mockPets

class MatchState {
  final List<PetModel> discoveryPets;
  final List<MatchRequestModel> myRequests; // Requests received by me
  final String? filterAnimal;
  final String? filterBreed;
  
  MatchState({
    this.discoveryPets = const [],
    this.myRequests = const [],
    this.filterAnimal,
    this.filterBreed,
  });

  MatchState copyWith({
    List<PetModel>? discoveryPets,
    List<MatchRequestModel>? myRequests,
    String? filterAnimal,
    String? filterBreed,
  }) {
    return MatchState(
      discoveryPets: discoveryPets ?? this.discoveryPets,
      myRequests: myRequests ?? this.myRequests,
      filterAnimal: filterAnimal ?? this.filterAnimal,
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
    _applyFilters(state.filterAnimal, breed);
  }

  void setFilterAnimal(String? animal) {
    // When changing animal, maybe reset breed since breeds are animal-specific
    _applyFilters(animal, null);
  }

  void _applyFilters(String? animal, String? breed) {
    var available = mockPets.where((pet) => pet.id != 'pet-1').toList();
    if (animal != null && animal.isNotEmpty) {
      available = available.where((p) => p.animalType == animal).toList();
    }
    if (breed != null && breed.isNotEmpty) {
      available = available.where((p) => p.breed == breed).toList();
    }
    state = MatchState(
       discoveryPets: available,
       myRequests: List.from(state.myRequests),
       filterAnimal: animal,
       filterBreed: breed,
    );
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
