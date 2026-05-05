import 'dart:developer' as developer;

import '../utils/supabase_config.dart';

class PushTokenRepository {
  Future<void> upsertToken({
    required String userId,
    required String fcmToken,
    String platform = 'android',
  }) async {
    try {
      await supabase.from('user_fcm_tokens').upsert(
        {
          'user_id': userId,
          'fcm_token': fcmToken,
          'platform': platform,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,fcm_token',
      );
    } catch (e, st) {
      developer.log(
        'push token upsert failed',
        name: 'PushTokenRepository',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> deleteToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      await supabase
          .from('user_fcm_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('fcm_token', fcmToken);
    } catch (e, st) {
      developer.log(
        'push token delete failed',
        name: 'PushTokenRepository',
        error: e,
        stackTrace: st,
      );
    }
  }
}

final pushTokenRepository = PushTokenRepository();