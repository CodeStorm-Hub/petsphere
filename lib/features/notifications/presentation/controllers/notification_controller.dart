import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petfolio/core/constants/app_durations.dart';
import 'package:petfolio/core/constants/app_strings.dart';
import 'package:petfolio/core/utils/logger.dart';

import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/notifications/data/models/notification_model.dart';
import 'package:petfolio/features/notifications/data/notification_repository.dart';

class NotificationState {
  const NotificationState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });
  final List<NotificationModel> items;
  final bool isLoading;
  final String? error;

  int get unreadCount =>
      items.where((n) => !n.isRead && n.type != 'message').length;
  int get unreadMessageCount =>
      items.where((n) => !n.isRead && n.type == 'message').length;

  NotificationState copyWith({
    List<NotificationModel>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => NotificationState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

class NotificationController extends Notifier<NotificationState> {
  RealtimeChannel? _channel;
  String? _userId;

  @override
  NotificationState build() {
    // Pre-set _userId so the auth listener below doesn't trigger a second
    // _rebindTo call for the same user that the microtask is about to bind.
    final userId = ref.read(authProvider).user?.id;
    _userId = userId;

    ref.listen(authProvider, (prev, next) {
      final nextId = next.user?.id;
      if (nextId != _userId) {
        _rebindTo(nextId);
      }
    });
    ref.onDispose(() => _channel?.unsubscribe());

    Future.microtask(() => _rebindTo(userId));
    return const NotificationState(isLoading: true);
  }

  void _rebindTo(String? userId) {
    _userId = userId;
    _channel?.unsubscribe();
    _channel = null;

    if (userId == null) {
      state = const NotificationState();
      return;
    }

    _fetch(userId);
    _channel = notificationRepository.subscribeForUser(
      userId: userId,
      onNew: (n) {
        if (state.items.any((x) => x.id == n.id)) return;
        state = state.copyWith(items: [n, ...state.items]);
      },
    );
  }

  Future<void> _fetch(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await notificationRepository
          .fetchForUser(userId)
          .timeout(AppDurations.defaultNetworkTimeout);
      state = state.copyWith(items: items, isLoading: false);
    } on TimeoutException catch (e) {
      AppLogger.error(
        AppStrings.timeoutError,
        tag: 'NotificationController',
        error: e,
      );
      state = state.copyWith(isLoading: false, error: AppStrings.timeoutError);
    } catch (e) {
      AppLogger.error(
        AppStrings.notificationLoadFailed,
        tag: 'NotificationController',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.notificationLoadFailed,
      );
    }
  }

  Future<void> refresh() async {
    final id = _userId;
    if (id != null) await _fetch(id);
  }

  Future<void> markAsRead(String id) async {
    state = state.copyWith(
      items: state.items
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );
    try {
      await notificationRepository.markAsRead(id);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    final id = _userId;
    if (id == null) return;
    state = state.copyWith(
      items: state.items.map((n) {
        if (n.type == 'message') return n;
        return n.copyWith(isRead: true);
      }).toList(),
    );
    try {
      await notificationRepository.markAllAsRead(id, excludeType: 'message');
    } catch (_) {}
  }

  Future<void> markMessagesAsRead() async {
    final id = _userId;
    if (id == null) return;
    state = state.copyWith(
      items: state.items.map((n) {
        if (n.type != 'message') return n;
        return n.copyWith(isRead: true);
      }).toList(),
    );
    try {
      await notificationRepository.markMessagesAsRead(id);
    } catch (_) {}
  }
}

final notificationProvider =
    NotifierProvider<NotificationController, NotificationState>(
      NotificationController.new,
    );
