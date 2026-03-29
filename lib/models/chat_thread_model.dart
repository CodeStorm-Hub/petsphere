import 'pet_model.dart';
import 'message_model.dart';

class ChatThreadModel {
  final String id;
  final List<String> participantPetIds; // The IDs of pets in the chat
  final List<PetModel> participantPets; // Full pet models for easy mock UI rendering
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  ChatThreadModel({
    required this.id,
    required this.participantPetIds,
    this.participantPets = const [],
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  ChatThreadModel copyWith({
    String? id,
    List<String>? participantPetIds,
    List<PetModel>? participantPets,
    MessageModel? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ChatThreadModel(
      id: id ?? this.id,
      participantPetIds: participantPetIds ?? this.participantPetIds,
      participantPets: participantPets ?? this.participantPets,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
