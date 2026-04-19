import 'package:pet_dating_app/models/pet_model.dart';
import 'package:pet_dating_app/models/message_model.dart';

class ChatThreadModel {
  final String id;
  final List<String> participantPetIds;
  final List<PetModel> participantPets;
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

  /// Parse from: chat_threads joined with pet1:pets!pet_id_1(*) and pet2:pets!pet_id_2(*)
  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    final pet1Json = json['pet1'] as Map<String, dynamic>?;
    final pet2Json = json['pet2'] as Map<String, dynamic>?;
    final pet1Id = json['pet_id_1'] as String;
    final pet2Id = json['pet_id_2'] as String;

    final pets = <PetModel>[
      if (pet1Json != null) PetModel.fromJson({...pet1Json, 'user_id': pet1Json['user_id'] ?? ''}),
      if (pet2Json != null) PetModel.fromJson({...pet2Json, 'user_id': pet2Json['user_id'] ?? ''}),
    ];

    final lastMsgJson = json['last_message'] as Map<String, dynamic>?;

    return ChatThreadModel(
      id: json['id'] as String,
      participantPetIds: [pet1Id, pet2Id],
      participantPets: pets,
      lastMessage:
          lastMsgJson != null ? MessageModel.fromJson(lastMsgJson) : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
