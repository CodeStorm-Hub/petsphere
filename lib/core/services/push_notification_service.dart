import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:petfolio/firebase_options.dart';
import 'package:petfolio/core/services/push_token_repository.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  developer.log(
    'Background FCM: ${message.messageId}',
    name: 'PushNotificationService',
  );
}

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static bool _initialized = false;
  static String? _lastRegisteredToken;
  static String? _activeUserId;
  static StreamSubscription<String>? _tokenRefreshSub;
  static StreamSubscription<RemoteMessage>? _openedSub;
  static bool _handledInitialMessage = false;

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log(
          'Foreground FCM: ${message.notification?.title}',
          name: 'PushNotificationService',
        );
      });
      _initialized = true;
      return true;
    } catch (e, st) {
      developer.log(
        'Firebase init failed (add google-services.json + flutterfire configure)',
        name: 'PushNotificationService',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Registers a handler that runs when the user taps a push notification.
  ///
  /// Covers:
  /// - Cold start: getInitialMessage()
  /// - Background: onMessageOpenedApp
  static Future<void> registerOnNotificationOpenedHandler(
    void Function(RemoteMessage message) onOpened,
  ) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    if (!_handledInitialMessage) {
      _handledInitialMessage = true;
      try {
        final initial = await _messaging.getInitialMessage();
        if (initial != null) onOpened(initial);
      } catch (_) {}
    }

    await _openedSub?.cancel();
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(onOpened);
  }

  /// Emit registration token to logs for Firebase Console "Send test message".
  /// Run: `flutter run --dart-define=FCM_LOG_TOKEN=true` and read logcat for `FCM_REGISTRATION_TOKEN=`.
  static Future<void> debugEmitFcmTokenForConsoleTest() async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }
    await requestUserPermission();
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM_REGISTRATION_TOKEN=(empty)');
        return;
      }
      debugPrint('FCM_REGISTRATION_TOKEN=$token');
    } catch (e, st) {
      developer.log(
        'FCM_REGISTRATION_TOKEN fetch failed',
        name: 'FCM_TEST',
        error: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> requestUserPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
    await _messaging.requestPermission();
  }

  static Future<void> registerTokenForUser(String userId) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }
    await requestUserPermission();
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      _lastRegisteredToken = token;
      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : 'android';
      await pushTokenRepository.upsertToken(
        userId: userId,
        fcmToken: token,
        platform: platform,
      );
      await _tokenRefreshSub?.cancel();
      _activeUserId = userId;
      _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
        newToken,
      ) {
        _lastRegisteredToken = newToken;
        final u = _activeUserId;
        if (u == null) return;
        pushTokenRepository.upsertToken(
          userId: u,
          fcmToken: newToken,
          platform: platform,
        );
      });
    } catch (e, st) {
      developer.log(
        'FCM getToken failed',
        name: 'PushNotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> clearTokenForUser(String userId) async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    _activeUserId = null;
    await _openedSub?.cancel();
    _openedSub = null;
    final token = _lastRegisteredToken;
    if (token != null) {
      await pushTokenRepository.deleteToken(userId: userId, fcmToken: token);
    }
    try {
      await _messaging.deleteToken();
    } catch (_) {}
    _lastRegisteredToken = null;
  }
}
