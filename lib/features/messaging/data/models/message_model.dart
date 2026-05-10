class MessageModel {

  MessageModel({
    required this.id,
    required this.threadId,
    required this.senderPetId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      senderPetId: json['sender_pet_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
  final String id;
  final String threadId;
  final String senderPetId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  MessageModel copyWith({
    String? id,
    String? threadId,
    String? senderPetId,
    String? text,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      senderPetId: senderPetId ?? this.senderPetId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    'thread_id': threadId,
    'sender_pet_id': senderPetId,
    'text': text,
    'is_read': isRead,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          threadId == other.threadId &&
          senderPetId == other.senderPetId &&
          text == other.text &&
          createdAt == other.createdAt &&
          isRead == other.isRead;

  @override
  int get hashCode =>
      id.hashCode ^
      threadId.hashCode ^
      senderPetId.hashCode ^
      text.hashCode ^
      createdAt.hashCode ^
      isRead.hashCode;
}
