import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
import 'feed_controller.dart';
import 'health_controller.dart';
import 'marketplace_controller.dart';
import 'notification_controller.dart';
import 'pet_care_controller.dart';
import 'pet_controller.dart';

/// Immutable snapshot for the app bootstrap / data sync coordinator.
class BootstrapState {
  const BootstrapState({
    this.lastHydratedUserId,
    this.isRefreshing = false,
  });

  /// Last user id for whom a successful automatic hydrate completed.
  final String? lastHydratedUserId;

  /// True while a user-initiated [BootstrapNotifier.syncAllData] run is in flight.
  final bool isRefreshing;

  BootstrapState copyWith({
    String? lastHydratedUserId,
    bool? isRefreshing,
    bool clearLastHydratedUserId = false,
  }) {
    if (clearLastHydratedUserId) {
      return BootstrapState(
        lastHydratedUserId: null,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );
    }
    return BootstrapState(
      lastHydratedUserId: lastHydratedUserId ?? this.lastHydratedUserId,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Coordinates hydrating primary data when the session becomes authenticated or
/// the active user id changes, and exposes an explicit full refresh for the
/// current session (same user).
///
/// Automatic triggers:
///   1. Cold start with a saved session (safety net in [build]).
///   2. Transition to [AuthStatus.authenticated] or user id change.
///
/// Supabase token refresh does not re-run hydration (handled in [AuthNotifier]).
///
/// Primary providers loaded here: [feedProvider], [marketplaceProvider],
/// [petProvider], [notificationProvider], [petCareProvider], [healthProvider].
///
/// [chatProvider] and [matchProvider] are not hydrated here; they follow
/// [activePetProvider] after pets load.
class BootstrapNotifier extends Notifier<BootstrapState> {
  /// Serializes all hydration work so cold-start, resume sync, and manual sync
  /// never run [Future.wait] concurrently against the same repositories.
  Future<void> _refreshChain = Future<void>.value();

  @override
  BootstrapState build() {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        final uid = next.user!.id;
        final becameAuthenticated = prev?.status != AuthStatus.authenticated;
        final userChanged = prev?.user?.id != uid;
        if (becameAuthenticated || userChanged) {
          unawaited(_performDataRefresh(uid, force: false));
        }
      } else if (next.status == AuthStatus.unauthenticated) {
        state = state.copyWith(clearLastHydratedUserId: true);
      }
    });

    final auth = ref.read(authProvider);
    if (auth.status == AuthStatus.authenticated && auth.user != null) {
      unawaited(_performDataRefresh(auth.user!.id, force: false));
    }

    return const BootstrapState();
  }

  /// Reloads all bootstrap targets for the signed-in user.
  ///
  /// When [force] is false, skips if [BootstrapState.lastHydratedUserId]
  /// already matches (same as automatic hydration).
  /// When [force] is true, always runs refreshes (e.g. Settings "Sync all data")
  /// without requiring logout/login.
  Future<void> syncAllData({bool force = false}) async {
    if (state.isRefreshing) return;

    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated || auth.user == null) {
      return;
    }

    state = state.copyWith(isRefreshing: true);
    try {
      await _performDataRefresh(auth.user!.id, force: force);
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isRefreshing: false);
      }
    }
  }

  Future<void> _performDataRefresh(String userId, {required bool force}) async {
    final previous = _refreshChain;
    final done = Completer<void>();
    _refreshChain = done.future;
    await previous;
    try {
      if (!force && state.lastHydratedUserId == userId) {
        debugPrint('[bootstrap] skip hydrate (already hydrated for $userId)');
        return;
      }
      final prev = state.lastHydratedUserId;
      final isAccountSwitch = prev != null && prev != userId;
      state = state.copyWith(lastHydratedUserId: userId);
      debugPrint('[bootstrap] hydrating data for user=$userId '
          '(force=$force, accountSwitch=$isAccountSwitch)');

      await Future.wait<void>([
        ref.read(feedProvider.notifier).refresh(),
        ref.read(marketplaceProvider.notifier).refresh(),
        ref.read(petProvider.notifier).reload(),
        ref.read(notificationProvider.notifier).refresh(),
        ref.read(petCareProvider.notifier).refresh(),
        ref.read(healthProvider.notifier).refresh(),
      ]);
    } finally {
      done.complete();
    }
  }
}

final bootstrapProvider =
    NotifierProvider<BootstrapNotifier, BootstrapState>(BootstrapNotifier.new);
