class NotificationModel {
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
}
