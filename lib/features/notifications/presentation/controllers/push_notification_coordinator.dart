import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petsphere/app/router.dart';
import 'package:petsphere/core/services/push_notification_service.dart';
import 'package:petsphere/core/services/push_deeplink_routes.dart';
import 'package:petsphere/features/auth/presentation/controllers/auth_controller.dart';

class PushNotificationCoordinator extends Notifier<void> {
  @override
  void build() {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        final uid = next.user!.id;
        final becameAuthenticated = prev?.status != AuthStatus.authenticated;
        final userChanged = prev?.user?.id != uid;
        if (becameAuthenticated || userChanged) {
          _schedule(() => PushNotificationService.registerTokenForUser(uid));
          _schedule(() async {
            await PushNotificationService.registerOnNotificationOpenedHandler((
              message,
            ) {
              final route = routeForPushPayload(message.data);
              ref.read(routerProvider).go(route);
            });
          });
        }
      } else if (next.status == AuthStatus.unauthenticated) {
        final prevUserId = prev?.user?.id;
        if (prevUserId != null) {
          _schedule(
            () => PushNotificationService.clearTokenForUser(prevUserId),
          );
        }
      }
    });

    final auth = ref.read(authProvider);
    if (auth.status == AuthStatus.authenticated && auth.user != null) {
      _schedule(
        () => PushNotificationService.registerTokenForUser(auth.user!.id),
      );
      _schedule(() async {
        await PushNotificationService.registerOnNotificationOpenedHandler((
          message,
        ) {
          final route = routeForPushPayload(message.data);
          ref.read(routerProvider).go(route);
        });
      });
    }
  }

  void _schedule(Future<void> Function() task) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(task());
    });
  }
}

final pushNotificationCoordinatorProvider =
    NotifierProvider<PushNotificationCoordinator, void>(
      PushNotificationCoordinator.new,
    );
