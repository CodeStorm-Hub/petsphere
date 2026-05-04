import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../utils/supabase_config.dart';

class NotificationRepository {
  Future<List<NotificationModel>> fetchForUser(String userId,
      {int limit = 50}) async {
    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List<dynamic>)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> unreadCount(String userId) async {
    final data = await supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (data as List).length;
  }

  Future<void> markAsRead(String notificationId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId, {String? excludeType}) async {
    var query = supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);

    if (excludeType != null) {
      query = query.neq('type', excludeType);
    }
    await query;
  }

  Future<void> markMessagesAsRead(String userId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('type', 'message')
        .eq('is_read', false);
  }

  Future<void> sendNotification({
    required String targetUserId,
    required String title,
    String? body,
    String? type,
    String? entityType,
    String? entityId,
    String? actorPetId,
  }) async {
    try {
      await supabase.from('notifications').insert({
        'user_id': targetUserId,
        'title': title,
        'body': body,
        'type': type,
        'entity_type': entityType,
        'entity_id': entityId,
        'actor_pet_id': actorPetId,
      });
    } catch (e, st) {
      developer.log(
        'sendNotification insert failed',
        name: 'NotificationRepository',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Real-time INSERT subscription for a specific user.
  RealtimeChannel subscribeForUser({
    required String userId,
    required void Function(NotificationModel notification) onNew,
  }) {
    return supabase
        .channel('notifications-user-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              final model = NotificationModel.fromJson(payload.newRecord);
              onNew(model);
            } catch (e, st) {
              developer.log(
                'Notification realtime parse failed',
                name: 'NotificationRepository',
                error: e,
                stackTrace: st,
              );
            }
          },
        )
        .subscribe();
  }
}

final notificationRepository = NotificationRepository();
