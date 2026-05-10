import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:petfolio/app/router.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/app/bootstrap_controller.dart';
import 'package:petfolio/features/notifications/presentation/controllers/push_notification_coordinator.dart';
import 'package:petfolio/core/theme/theme_controller.dart';
import 'package:petfolio/core/theme/app_theme.dart';

class PetFolioApp extends ConsumerWidget {
  const PetFolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    ref.watch(bootstrapProvider);
    ref.watch(pushNotificationCoordinatorProvider);

    final themeMode = ref.watch(themeProvider);

    return _AppLifecycleBootstrapSync(
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return MaterialApp.router(
            title: 'PetFolio',
            theme: AppTheme.lightTheme.copyWith(
              colorScheme: lightDynamic ?? AppTheme.lightTheme.colorScheme,
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              colorScheme: darkDynamic ?? AppTheme.darkTheme.colorScheme,
            ),
            themeMode: themeMode,
            routerConfig: goRouter,
            debugShowCheckedModeBanner: false,
          );
        },
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

    final returnedFromBackground =
        prev == AppLifecycleState.paused ||
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
