import 'pet_model.dart';

class MatchRequestModel {
  final String id;
  final String senderPetId;
  final String receiverPetId;
  final String status; // 'pending', 'matched', 'rejected'
  final DateTime createdAt;
  
  // Helpful for the mock UI to easily render the sender profile
  final PetModel? senderPet;

  MatchRequestModel({
    required this.id,
    required this.senderPetId,
    required this.receiverPetId,
    this.status = 'pending',
    required this.createdAt,
    this.senderPet,
  });

  MatchRequestModel copyWith({
    String? id,
    String? senderPetId,
    String? receiverPetId,
    String? status,
    DateTime? createdAt,
    PetModel? senderPet,
  }) {
    return MatchRequestModel(
      id: id ?? this.id,
      senderPetId: senderPetId ?? this.senderPetId,
      receiverPetId: receiverPetId ?? this.receiverPetId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      senderPet: senderPet ?? this.senderPet,
    );
  }
}
