/// Maps push notification payloads to in-app routes.
///
/// The Edge Function `push-fcm` currently sends:
/// - data.type
/// - data.entity_type
/// - data.entity_id
///
/// This helper is tolerant to missing keys and returns a safe fallback.
String routeForPushPayload(Map<String, dynamic> data) {
  final entityType = (data['entity_type'] ?? data['entityType'])?.toString();
  final entityId = (data['entity_id'] ?? data['entityId'])?.toString();

  if (entityType == null || entityType.isEmpty) return '/notifications';

  switch (entityType) {
    case 'post':
      return (entityId == null || entityId.isEmpty)
          ? '/notifications'
          : '/post/$entityId';
    case 'chat_thread':
    case 'thread':
      return (entityId == null || entityId.isEmpty)
          ? '/notifications'
          : '/chat/$entityId';
    case 'product':
      return (entityId == null || entityId.isEmpty)
          ? '/notifications'
          : '/product/$entityId';
    case 'notification':
      return '/notifications';
    default:
      return '/notifications';
  }
}

