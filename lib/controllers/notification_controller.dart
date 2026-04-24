import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import 'auth_controller.dart';

class NotificationState {
  final List<NotificationModel> items;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationModel>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      NotificationState(
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
    ref.listen(authProvider, (prev, next) {
      final nextId = next.user?.id;
      if (nextId != _userId) {
        _rebindTo(nextId);
      }
    });
    ref.onDispose(() => _channel?.unsubscribe());

    final userId = ref.read(authProvider).user?.id;
    _rebindTo(userId);
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
      final items = await notificationRepository.fetchForUser(userId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
      items: state.items.map((n) => n.copyWith(isRead: true)).toList(),
    );
    try {
      await notificationRepository.markAllAsRead(id);
    } catch (_) {}
  }
}

final notificationProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);
