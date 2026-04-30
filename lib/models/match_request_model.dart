import 'pet_model.dart';

class MatchRequestModel {
  final String id;
  final String senderPetId;
  final String receiverPetId;
  final String status; // 'pending', 'matched', 'rejected'
  final DateTime createdAt;
  final PetModel? senderPet;
  final PetModel? receiverPet;

  MatchRequestModel({
    required this.id,
    required this.senderPetId,
    required this.receiverPetId,
    this.status = 'pending',
    required this.createdAt,
    this.senderPet,
    this.receiverPet,
  });

  MatchRequestModel copyWith({
    String? id,
    String? senderPetId,
    String? receiverPetId,
    String? status,
    DateTime? createdAt,
    PetModel? senderPet,
    PetModel? receiverPet,
  }) {
    return MatchRequestModel(
      id: id ?? this.id,
      senderPetId: senderPetId ?? this.senderPetId,
      receiverPetId: receiverPetId ?? this.receiverPetId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      senderPet: senderPet ?? this.senderPet,
      receiverPet: receiverPet ?? this.receiverPet,
    );
  }

  factory MatchRequestModel.fromJson(Map<String, dynamic> json) {
    final senderJson = json['sender_pets'] as Map<String, dynamic>?;
    final receiverJson = json['receiver_pets'] as Map<String, dynamic>?;
    return MatchRequestModel(
      id: json['id'] as String,
      senderPetId: json['sender_pet_id'] as String,
      receiverPetId: json['receiver_pet_id'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      senderPet: senderJson != null ? PetModel.fromJson(senderJson) : null,
      receiverPet:
          receiverJson != null ? PetModel.fromJson(receiverJson) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'sender_pet_id': senderPetId,
        'receiver_pet_id': receiverPetId,
        'status': status,
      };
}
