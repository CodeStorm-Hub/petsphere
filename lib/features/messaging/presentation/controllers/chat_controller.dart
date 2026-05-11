import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petfolio/core/constants/app_durations.dart';
import 'package:petfolio/features/messaging/data/models/chat_thread_model.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/messaging/data/models/message_model.dart';
import 'package:petfolio/features/messaging/data/chat_repository.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/core/constants/app_strings.dart';
import 'package:petfolio/core/utils/logger.dart';

// ---------------------------------------------------------------------------
// Per-Thread Messages State (with Realtime)
// We expose a regular StateNotifier-style notifier.
// The screen calls init(threadId) in initState to start loading + Realtime.
// ---------------------------------------------------------------------------
class ThreadMessagesNotifier extends Notifier<List<MessageModel>> {
  RealtimeChannel? _channel;
  String? _threadId;

  @override
  List<MessageModel> build() {
    ref.onDispose(() {
      if (_channel != null) supabase.removeChannel(_channel!);
    });
    return [];
  }

  Future<void> init(String threadId) async {
    _threadId = threadId;

    // Clear immediately so a fast thread switch never shows the prior thread.
    state = [];
    if (_channel != null) unawaited(supabase.removeChannel(_channel!));
    _channel = null;

    // Load initial messages
    try {
      final messages = await chatRepository
          .fetchMessages(threadId)
          .timeout(AppDurations.defaultNetworkTimeout);
      if (_threadId != threadId) return;
      state = messages;
    } catch (e, st) {
      developer.log(
        'fetchMessages failed',
        name: 'ThreadMessagesNotifier',
        error: e,
        stackTrace: st,
      );
      if (_threadId == threadId) state = [];
    }

    // Subscribe to real-time updates
    _channel = chatRepository.subscribeToMessages(
      threadId: threadId,
      onMessage: (message) {
        if (_threadId != threadId) return;
        if (!state.any((m) => m.id == message.id)) {
          state = [...state, message];
        }
      },
    );
  }

  Future<void> sendMessage(String senderPetId, String text) async {
    final threadId = _threadId;
    if (text.trim().isEmpty || threadId == null) return;

    // Optimistic update
    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      threadId: threadId,
      senderPetId: senderPetId,
      text: text.trim(),
      createdAt: DateTime.now(),
      isRead: true,
    );
    state = [...state, optimistic];

    try {
      final sent = await chatRepository.sendMessage(
        threadId: threadId,
        senderPetId: senderPetId,
        text: text.trim(),
      );
      // Replace temp message with real one (Realtime will also fire but we
      // deduplicate by ID in the subscription callback above)
      state = state.map((m) => m.id == tempId ? sent : m).toList();

      // Message notifications are handled by the DB trigger
      // (notify_on_new_message) to avoid duplicates.
    } catch (e, st) {
      developer.log(
        'sendMessage failed',
        name: 'ThreadMessagesNotifier',
        error: e,
        stackTrace: st,
      );
      // Rollback optimistic message
      state = state.where((m) => m.id != tempId).toList();
    }
  }

  List<MessageModel> getMessages() => state;
}

/// Provider is intentionally NOT auto-disposed so the Realtime subscription
/// survives soft navigations. The RealtimeChannel is cancelled in onDispose
/// which fires when the ProviderScope is removed.
final threadMessagesProvider =
    NotifierProvider<ThreadMessagesNotifier, List<MessageModel>>(
      ThreadMessagesNotifier.new,
    );

// ---------------------------------------------------------------------------
// Chat Threads List State
// ---------------------------------------------------------------------------
class ChatState {
  ChatState({this.threads = const [], this.isLoading = false, this.error});
  final List<ChatThreadModel> threads;
  final bool isLoading;
  final String? error;

  int get totalUnread => threads.fold(0, (sum, t) => sum + t.unreadCount);

  ChatState copyWith({
    List<ChatThreadModel>? threads,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      threads: threads ?? this.threads,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends Notifier<ChatState> {
  RealtimeChannel? _messagesChannel;
  int _fetchGeneration = 0;

  @override
  ChatState build() {
    ref.onDispose(() {
      if (_messagesChannel != null) supabase.removeChannel(_messagesChannel!);
      _messagesChannel = null;
    });

    ref.listen<PetModel?>(activePetProvider, (previous, next) {
      if (_messagesChannel != null) supabase.removeChannel(_messagesChannel!);
      _messagesChannel = null;
      if (next == null) {
        Future.microtask(() {
          state = ChatState();
        });
        return;
      }
      _loadThreads(next.id);
    }, fireImmediately: true);

    final activePet = ref.read(activePetProvider);
    return ChatState(isLoading: activePet != null);
  }

  Future<void> _loadThreads(String myPetId) async {
    final currentGen = ++_fetchGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final threads = await chatRepository
          .fetchThreads(myPetId)
          .timeout(AppDurations.defaultNetworkTimeout);

      // Fetch all unread counts in a single batch query
      final threadIds = threads.map((t) => t.id).toList();
      final unreadCounts = await chatRepository
          .fetchUnreadCountsForThreads(threadIds, myPetId)
          .timeout(AppDurations.defaultNetworkTimeout);

      if (_fetchGeneration != currentGen) return;

      final threadsWithCounts = threads
          .map((t) => t.copyWith(unreadCount: unreadCounts[t.id] ?? 0))
          .toList();

      state = state.copyWith(threads: threadsWithCounts, isLoading: false);
      _subscribeToIncomingMessages(myPetId);
    } catch (e) {
      if (_fetchGeneration != currentGen) return;
      AppLogger.error(
        AppStrings.chatLoadFailed,
        tag: 'ChatController',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.chatLoadFailed,
      );
    }
  }

  void _subscribeToIncomingMessages(String myPetId) {
    if (_messagesChannel != null) supabase.removeChannel(_messagesChannel!);
    final knownThreadIds = state.threads.map((t) => t.id).toSet();

    _messagesChannel = chatRepository.subscribeToAllMessages(
      onMessage: (msg) {
        // Ignore own messages (already added optimistically)
        if (msg.senderPetId == myPetId) return;
        if (!knownThreadIds.contains(msg.threadId)) return;

        state = state.copyWith(
          threads: state.threads.map((t) {
            if (t.id != msg.threadId) return t;
            return t.copyWith(lastMessage: msg, unreadCount: t.unreadCount + 1);
          }).toList(),
        );
      },
    );
  }

  Future<void> refresh() async {
    final activePet = ref.read(activePetProvider);
    if (activePet != null) await _loadThreads(activePet.id);
  }

  Future<String?> createOrGetThread(String otherPetId) async {
    final activePet = ref.read(activePetProvider);
    if (activePet == null) return null;
    try {
      final threadId = await chatRepository.createOrGetThread(
        activePet.id,
        otherPetId,
      );
      await _loadThreads(activePet.id);
      return threadId;
    } catch (e) {
      AppLogger.error(
        AppStrings.chatThreadCreationFailed,
        tag: 'ChatController',
        error: e,
      );
      state = state.copyWith(error: AppStrings.chatThreadCreationFailed);
      return null;
    }
  }

  /// When navigating directly to `/chat/:id`, the thread may not yet appear in
  /// [state.threads]. Fetch that row (with participant pets) and merge it in.
  Future<void> ensureThreadLoaded(String threadId) async {
    if (state.threads.any((t) => t.id == threadId)) return;

    final activePet = ref.read(activePetProvider);
    if (activePet == null) return;

    try {
      final thread = await chatRepository
          .fetchThreadById(threadId, activePet.id)
          .timeout(AppDurations.defaultNetworkTimeout);
      if (thread == null) return;

      final unreadCounts = await chatRepository
          .fetchUnreadCountsForThreads([threadId], activePet.id)
          .timeout(AppDurations.defaultNetworkTimeout);
      final merged = thread.copyWith(
        unreadCount: unreadCounts[threadId] ?? thread.unreadCount,
      );

      if (state.threads.any((t) => t.id == threadId)) return;
      state = state.copyWith(threads: [merged, ...state.threads]);
    } catch (e, st) {
      AppLogger.error(
        AppStrings.chatHeaderLoadFailed,
        tag: 'ChatController',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(error: AppStrings.chatHeaderLoadFailed);
    }
  }

  Future<void> markThreadAsRead(String threadId) async {
    final activePet = ref.read(activePetProvider);
    if (activePet == null) return;
    await chatRepository.markThreadAsRead(threadId, activePet.id);
    state = state.copyWith(
      threads: state.threads.map((t) {
        if (t.id == threadId) return t.copyWith(unreadCount: 0);
        return t;
      }).toList(),
    );
  }
}

final chatProvider = NotifierProvider<ChatController, ChatState>(() {
  return ChatController();
});
