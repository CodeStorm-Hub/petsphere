class MessageModel {
  final String id;
  final String threadId;
  final String senderPetId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.threadId,
    required this.senderPetId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

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
}
