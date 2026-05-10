import 'package:petsphere/features/pet/data/models/pet_model.dart';
import 'package:petsphere/features/messaging/data/models/message_model.dart';

class ChatThreadModel {
  final String id;
  final List<String> participantPetIds;
  final List<PetModel> participantPets;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const ChatThreadModel({
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

  /// Parse from: chat_threads joined with pet1:pets!pet_id_1(*) and pet2:pets!pet_id_2(*).
  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    final pet1Json = json['pet1'] as Map<String, dynamic>?;
    final pet2Json = json['pet2'] as Map<String, dynamic>?;
    final pet1Id = json['pet_id_1'] as String;
    final pet2Id = json['pet_id_2'] as String;

    final pets = <PetModel>[
      if (pet1Json != null)
        PetModel.fromJson({...pet1Json, 'user_id': pet1Json['user_id'] ?? ''}),
      if (pet2Json != null)
        PetModel.fromJson({...pet2Json, 'user_id': pet2Json['user_id'] ?? ''}),
    ];

    final lastMsgJson = json['last_message'] as Map<String, dynamic>?;

    return ChatThreadModel(
      id: json['id'] as String,
      participantPetIds: [pet1Id, pet2Id],
      participantPets: pets,
      lastMessage: lastMsgJson != null
          ? MessageModel.fromJson(lastMsgJson)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pet_id_1': participantPetIds.isNotEmpty ? participantPetIds[0] : '',
    'pet_id_2': participantPetIds.length > 1 ? participantPetIds[1] : '',
    'unread_count': unreadCount,
    'updated_at': updatedAt.toIso8601String(),
    if (lastMessage != null) 'last_message': lastMessage!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatThreadModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          participantPetIds == other.participantPetIds &&
          participantPets == other.participantPets &&
          lastMessage == other.lastMessage &&
          unreadCount == other.unreadCount &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      participantPetIds.hashCode ^
      participantPets.hashCode ^
      lastMessage.hashCode ^
      unreadCount.hashCode ^
      updatedAt.hashCode;
}
