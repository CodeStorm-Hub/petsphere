import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'feed_controller.dart';
import 'health_controller.dart';
import 'marketplace_controller.dart';
import 'notification_controller.dart';
import 'pet_care_controller.dart';
import 'pet_controller.dart';

/// Side-effect provider that hydrates every primary data source whenever the
/// user becomes authenticated.
///
/// It runs on three triggers:
///   1. **Cold start with a saved session** — when the auth status flips
///      from `initial` to `authenticated` after the splash screen finishes.
///   2. **Fresh login** — when the user signs in and the status changes
///      from `unauthenticated` to `authenticated`.
///   3. **Account switch** — when the active user ID changes between
///      authenticated states.
///
/// On each trigger it ensures these primary providers are materialised:
///   - [feedProvider]         (public posts)
///   - [marketplaceProvider]  (products)
///   - [petProvider]          (the current user's pets)
///   - [notificationProvider] (the current user's notifications)
///
/// The first time a provider is materialised, its `build()` runs an initial
/// fetch on its own. For account-switch scenarios where the providers are
/// already built, we explicitly call their `refresh()` / `reload()` so the
/// data is re-pulled for the new user. Each provider also has its own
/// auth listener that catches auth changes after it is built, so this
/// bootstrap is a complementary safety net rather than the only path.
///
/// `chatProvider` and `matchProvider` are intentionally NOT hydrated here —
/// they already react automatically to `activePetProvider` changes once
/// [petProvider] has loaded.
///
/// Manual refresh (every screen's `RefreshIndicator` + each notifier's
/// `refresh()` method) is fully preserved; this provider only adds an
/// additional automatic trigger so the user never has to pull-to-refresh
/// just to see initial content.
final bootstrapProvider = Provider<void>((ref) {
  String? lastHydratedUserId;

  void hydrate(String userId) {
    final isAccountSwitch =
        lastHydratedUserId != null && lastHydratedUserId != userId;
    final alreadyHydrated = lastHydratedUserId == userId;
    if (alreadyHydrated) return;
    lastHydratedUserId = userId;
    debugPrint(
        '[bootstrap] hydrating data for user=$userId (switch=$isAccountSwitch)');

    if (isAccountSwitch) {
      // Providers were already built for the previous user — force a
      // fresh fetch so stale data from that account is replaced.
      ref.read(feedProvider.notifier).refresh();
      ref.read(marketplaceProvider.notifier).refresh();
      ref.read(petProvider.notifier).reload();
      ref.read(notificationProvider.notifier).refresh();
      ref.read(petCareProvider.notifier).refresh();
      ref.read(healthProvider.notifier).refresh();
    } else {
      // First-time hydration in this session: just touch each provider so
      // its `build()` runs the initial fetch and registers its own auth
      // listener for future changes. Avoids redundant double-fetches.
      ref.read(feedProvider.notifier);
      ref.read(marketplaceProvider.notifier);
      ref.read(petProvider.notifier);
      ref.read(notificationProvider.notifier);
      // pet_care_controller and health_controller hook into activePetProvider,
      // so just materialise them once so their listeners register.
      ref.read(petCareProvider.notifier);
      ref.read(healthProvider.notifier);
    }
  }

  ref.listen<AuthState>(authProvider, (prev, next) {
    if (next.status == AuthStatus.authenticated && next.user != null) {
      hydrate(next.user!.id);
    } else if (next.status == AuthStatus.unauthenticated) {
      lastHydratedUserId = null;
    }
  });

  // Cold-start safety net: if the auth provider has already settled into
  // `authenticated` by the time this provider is first read, the listener
  // above would miss that transition. Hydrate immediately in that case.
  final auth = ref.read(authProvider);
  if (auth.status == AuthStatus.authenticated && auth.user != null) {
    hydrate(auth.user!.id);
  }
});
