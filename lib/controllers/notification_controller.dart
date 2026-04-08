import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../utils/supabase_config.dart';
import 'auth_controller.dart';

class NotificationState {
  final List<AppNotificationModel> notifications;
  final bool isLoading;
  final int unreadCount;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.unreadCount = 0,
    this.error,
  });

  NotificationState copyWith({
    List<AppNotificationModel>? notifications,
    bool? isLoading,
    int? unreadCount,
    String? error,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      unreadCount: unreadCount ?? this.unreadCount,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NotificationController extends Notifier<NotificationState> {
  RealtimeChannel? _channel;
  String? _subscribedUserId;
  int _loadGen = 0;

  @override
  NotificationState build() {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id;

    ref.onDispose(() {
      _disposeSubscription();
    });

    if (authState.status == AuthStatus.authenticated && userId != null) {
      Future.microtask(() => _initialize(userId));
      return NotificationState(isLoading: true);
    }

    _disposeSubscription();
    return NotificationState();
  }

  Future<void> _initialize(String userId) async {
    if (_subscribedUserId != userId) {
      _disposeSubscription();
      _subscribedUserId = userId;
      _channel = notificationRepository.subscribeToNotifications(userId, () {
        _reload(userId);
      });
    }
    await _reload(userId);
  }

  Future<void> _reload(String userId) async {
    final gen = ++_loadGen;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final notifications =
          await notificationRepository.fetchUserNotifications(userId);
      final unreadCount = await notificationRepository.fetchUnreadCount(userId);
      if (gen != _loadGen) return;
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      if (gen != _loadGen) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;
    await _reload(userId);
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    final idx = state.notifications.indexWhere((n) => n.id == notificationId);
    if (idx < 0) return;

    final item = state.notifications[idx];
    if (item.isRead) return;

    final next = List<AppNotificationModel>.from(state.notifications);
    next[idx] = item.copyWith(isRead: true);
    state = state.copyWith(
      notifications: next,
      unreadCount: (state.unreadCount - 1).clamp(0, 1 << 30),
    );

    try {
      await notificationRepository.markAsRead(
        notificationId: notificationId,
        userId: userId,
      );
    } catch (e) {
      await _reload(userId);
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    final optimistic = state.notifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: optimistic, unreadCount: 0);

    try {
      await notificationRepository.markAllAsRead(userId);
      await _reload(userId);
    } catch (e) {
      await _reload(userId);
      state = state.copyWith(error: e.toString());
    }
  }

  void _disposeSubscription() {
    final channel = _channel;
    _channel = null;
    _subscribedUserId = null;
    if (channel != null) {
      supabase.removeChannel(channel);
    }
  }
}

final notificationProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});
