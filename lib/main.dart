import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'controllers/auth_controller.dart';
import 'controllers/bootstrap_controller.dart';
import 'controllers/theme_controller.dart';
import 'utils/routes.dart';
import 'utils/supabase_config.dart';
import 'theme/app_theme_v2_material3.dart';

/// Set via `flutter test integration_test/... --dart-define=INTEGRATION_TEST=true`
/// so [IntegrationTestWidgetsFlutterBinding] is not replaced by Marionette.
const bool _kIntegrationTest = bool.fromEnvironment(
  'INTEGRATION_TEST',
  defaultValue: false,
);

/// `flutter drive` + [enableFlutterDriverExtension] needs a normal binding in debug.
const bool _kFlutterDriverTest = bool.fromEnvironment(
  'FLUTTER_DRIVER_TEST',
  defaultValue: false,
);

Future<void> main() async {
  if (!_kIntegrationTest) {
    if (kDebugMode && !_kFlutterDriverTest) {
      MarionetteBinding.ensureInitialized();
    } else {
      WidgetsFlutterBinding.ensureInitialized();
    }
  }

  assertValidReleaseSupabaseConfig();
  await Supabase.initialize(
    url: supabaseInitUrl,
    anonKey: supabaseInitAnonKey,
  );

  runApp(const ProviderScope(child: PetSphereApp()));
}

class PetSphereApp extends ConsumerWidget {
  const PetSphereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the routerProvider to get the navigation configuration
    final goRouter = ref.watch(routerProvider);

    // Bootstrap coordinator: registers an auth listener, auto-hydrates on
    // login / user change / cold start, and exposes syncAllData(force: true)
    // from settings. Watching keeps the notifier alive.
    ref.watch(bootstrapProvider);

    final themeMode = ref.watch(themeProvider);

    return _AppLifecycleBootstrapSync(
      child: MaterialApp.router(
        title: 'PetSphere',
        theme: AppThemeV2.lightTheme,
        darkTheme: AppThemeV2.darkTheme,
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
