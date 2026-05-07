import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'controllers/auth_controller.dart';
import 'controllers/bootstrap_controller.dart';
import 'controllers/push_notification_coordinator.dart';
import 'controllers/theme_controller.dart';
import 'services/push_notification_service.dart';
import 'utils/routes.dart';
import 'utils/supabase_config.dart';
import 'utils/theme_bootstrap.dart';
import 'theme/app_theme.dart';

/// Set via `flutter test integration_test/... --dart-define=INTEGRATION_TEST=true`
/// so [IntegrationTestWidgetsFlutterBinding] is not replaced by Marionette.
const bool _kIntegrationTest = bool.fromEnvironment(
  'INTEGRATION_TEST',
  defaultValue: false,
);

/// `flutter drive` + [enableFlutterDriverExtension] needs a normal binding in debug.
const bool _kFlutterDriverTest = bool.fromEnvironment(
  'FLUTTER_DRIVER_TEST',
  defaultValue: true,
);

const bool _kFcmLogToken = bool.fromEnvironment(
  'FCM_LOG_TOKEN',
  defaultValue: false,
);

const String _kStripePublishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: '',
);

Future<void> main() async {
  if (!_kIntegrationTest) {
    if (kDebugMode && !_kFlutterDriverTest) {
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
      );
    }
  }

  if (_kFcmLogToken) {
    await PushNotificationService.debugEmitFcmTokenForConsoleTest();
  }

  final prefs = await SharedPreferences.getInstance();
  pendingBootstrapThemeMode =
      prefs.getString('theme_mode') == 'dark' ? ThemeMode.dark : ThemeMode.light;

  runApp(const ProviderScope(child: PetFolioApp()));
}

class PetFolioApp extends ConsumerWidget {
  const PetFolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the routerProvider to get the navigation configuration
    final goRouter = ref.watch(routerProvider);

    // Bootstrap coordinator: registers an auth listener, auto-hydrates on
    // login / user change / cold start, and exposes syncAllData(force: true)
    // from settings. Watching keeps the notifier alive.
    ref.watch(bootstrapProvider);
    ref.watch(pushNotificationCoordinatorProvider);

    final themeMode = ref.watch(themeProvider);

    return _AppLifecycleBootstrapSync(
      child: MaterialApp.router(
        title: 'PetFolio',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// After the app returns from background, optionally re-sync bootstrap data
/// so stale UI refreshes (debounced to limit API churn).
class _AppLifecycleBootstrapSync extends ConsumerStatefulWidget {
  const _AppLifecycleBootstrapSync({required this.child});

  final Widget child;

  @override
  ConsumerState<_AppLifecycleBootstrapSync> createState() =>
      _AppLifecycleBootstrapSyncState();
}

class _AppLifecycleBootstrapSyncState
    extends ConsumerState<_AppLifecycleBootstrapSync>
    with WidgetsBindingObserver {
  AppLifecycleState? _previousLifecycleState;
  DateTime? _lastResumeSyncAt;

  static const Duration _minIntervalBetweenResumeSyncs = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final prev = _previousLifecycleState;
    _previousLifecycleState = state;
    if (state != AppLifecycleState.resumed) return;

    final returnedFromBackground = prev == AppLifecycleState.paused ||
        prev == AppLifecycleState.inactive ||
        prev == AppLifecycleState.hidden;
    if (!returnedFromBackground) return;

    final now = DateTime.now();
    if (_lastResumeSyncAt != null &&
        now.difference(_lastResumeSyncAt!) < _minIntervalBetweenResumeSyncs) {
      return;
    }

    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated || auth.user == null) {
      return;
    }

    _lastResumeSyncAt = now;
    ref.read(bootstrapProvider.notifier).syncAllData(force: true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
