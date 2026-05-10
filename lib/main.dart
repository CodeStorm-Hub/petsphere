import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:petfolio/app/app.dart';
import 'package:petfolio/core/services/push_notification_service.dart';
import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/core/services/offline_cache.dart';
import 'package:petfolio/core/theme/theme_bootstrap.dart';
import 'package:petfolio/core/services/storage_service.dart';

/// Set via `flutter test integration_test/... --dart-define=INTEGRATION_TEST=true`
/// so [IntegrationTestWidgetsFlutterBinding] is not replaced by Marionette.
const bool _kIntegrationTest = bool.fromEnvironment('INTEGRATION_TEST');

/// `flutter drive` + [enableFlutterDriverExtension] needs a normal binding in debug.
const bool _kFlutterDriverTest = bool.fromEnvironment(
  'FLUTTER_DRIVER_TEST',
  defaultValue: true,
);

const bool _kFcmLogToken = bool.fromEnvironment('FCM_LOG_TOKEN');

const String _kStripePublishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
);

Future<void> main() async {
  await runZonedGuarded(
    () async {
      FlutterError.onError = (details) {
        developer.log(
          'Flutter framework error: ${details.exceptionAsString()}',
          name: 'FlutterError',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      if (!_kIntegrationTest) {
        const useMarionetteBinding = kDebugMode && !_kFlutterDriverTest;
        if (useMarionetteBinding) {
          MarionetteBinding.ensureInitialized();
        } else {
          WidgetsFlutterBinding.ensureInitialized();
        }
        PushNotificationService.registerBackgroundHandler();
      }

      assertValidReleaseSupabaseConfig();
      await Supabase.initialize(
        url: supabaseInitUrl,
        anonKey: supabaseInitAnonKey,
      );

      // Self-heal storage buckets (ensure they are public and exist)
      final storageService = StorageService(Supabase.instance.client);
      await storageService.initializeBuckets();

      if (_kStripePublishableKey.isNotEmpty) {
        try {
          Stripe.publishableKey = _kStripePublishableKey;
          await Stripe.instance.applySettings();
        } catch (e, st) {
          developer.log(
            'Stripe init failed (checkout disabled): $e',
            name: 'main',
            error: e,
            stackTrace: st,
            sequenceNumber: 0,
          );
        }
      }

      if (_kFcmLogToken) {
        await PushNotificationService.debugEmitFcmTokenForConsoleTest();
      }

      final prefs = await SharedPreferences.getInstance();

      // Initialize OfflineCache for persistence
      final offlineCache = OfflineCache();
      await offlineCache.initialize();

      pendingBootstrapThemeMode = prefs.getString('theme_mode') == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;

      runApp(const ProviderScope(child: PetFolioApp()));
    },
    (error, stackTrace) {
      developer.log(
        'Unhandled zoned error: $error',
        name: 'ZoneError',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
