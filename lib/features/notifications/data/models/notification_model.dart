class NotificationModel {

  NotificationModel({
    required this.id,
    required this.userId,
    this.actorPetId,
    required this.type,
    required this.title,
    this.body,
    this.entityType,
    this.entityId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      actorPetId: json['actor_pet_id'] as String?,
      type: json['type'] as String? ?? 'generic',
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      entityType: json['entity_type'] as String?,
      entityId: json['entity_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
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

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    userId: userId,
    actorPetId: actorPetId,
    type: type,
    title: title,
    body: body,
    entityType: entityType,
    entityId: entityId,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    if (actorPetId != null) 'actor_pet_id': actorPetId,
    'type': type,
    'title': title,
    if (body != null) 'body': body,
    if (entityType != null) 'entity_type': entityType,
    if (entityId != null) 'entity_id': entityId,
    'is_read': isRead,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          actorPetId == other.actorPetId &&
          type == other.type &&
          title == other.title &&
          body == other.body &&
          entityType == other.entityType &&
          entityId == other.entityId &&
          isRead == other.isRead &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      actorPetId.hashCode ^
      type.hashCode ^
      title.hashCode ^
      body.hashCode ^
      entityType.hashCode ^
      entityId.hashCode ^
      isRead.hashCode ^
      createdAt.hashCode;
}
