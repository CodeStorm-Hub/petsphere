class AppNotificationModel {
  final String id;
  final String userId;
  final String? actorPetId;
  final String type;
  final String title;
  final String? body;
  final String? entityType;
  final String? entityId;
  final bool isRead;
  final DateTime createdAt;

  AppNotificationModel({
    required this.id,
    required this.userId,
    required this.actorPetId,
    required this.type,
    required this.title,
    required this.body,
    required this.entityType,
    required this.entityId,
    required this.isRead,
    required this.createdAt,
  });

  AppNotificationModel copyWith({
    String? id,
    String? userId,
    String? actorPetId,
    String? type,
    String? title,
    String? body,
    String? entityType,
    String? entityId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      actorPetId: actorPetId ?? this.actorPetId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      actorPetId: json['actor_pet_id'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      entityType: json['entity_type'] as String?,
      entityId: json['entity_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'actor_pet_id': actorPetId,
      'type': type,
      'title': title,
      'body': body,
      'entity_type': entityType,
      'entity_id': entityId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
