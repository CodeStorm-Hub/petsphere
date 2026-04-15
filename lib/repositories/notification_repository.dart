import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';
import '../utils/supabase_config.dart';

class NotificationRepository {
  Future<List<AppNotificationModel>> fetchUserNotifications(
    String userId, {
    int limit = 100,
  }) async {
    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List<dynamic>)
        .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> fetchUnreadCount(String userId) async {
    final data = await supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return (data as List).length;
  }

  Future<void> markAsRead({
    required String notificationId,
    required String userId,
  }) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> markAllAsRead(String userId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  RealtimeChannel subscribeToNotifications(
    String userId,
    VoidCallback onChanged,
  ) {
    return supabase
        .channel('public:notifications:user:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => onChanged(),
        )
        .subscribe();
  }
}

final notificationRepository = NotificationRepository();
