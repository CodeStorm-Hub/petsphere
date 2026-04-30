import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_thread_model.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';
import '../repositories/notification_repository.dart';
import 'pet_controller.dart';

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
      _channel?.unsubscribe();
    });
    return [];
  }

  Future<void> init(String threadId) async {
    _threadId = threadId;

    // Load initial messages
    try {
      final messages = await chatRepository.fetchMessages(threadId);
      state = messages;
    } catch (_) {
      state = [];
    }

    // Subscribe to real-time updates
    _channel?.unsubscribe();
    _channel = chatRepository.subscribeToMessages(
      threadId: threadId,
      onMessage: (message) {
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

      // Notify the other pet's owner
      try {
        final threads = ref.read(chatProvider).threads;
        ChatThreadModel? thread;
        for (final t in threads) {
          if (t.id == threadId) {
            thread = t;
            break;
          }
        }
        if (thread != null) {
          for (final pet in thread.participantPets) {
            if (pet.id != senderPetId && pet.userId.isNotEmpty) {
              notificationRepository.sendNotification(
                targetUserId: pet.userId,
                title: 'New message',
                body: text.trim().length > 100
                    ? '${text.trim().substring(0, 100)}…'
                    : text.trim(),
                type: 'message',
                entityType: 'message',
                entityId: threadId,
                actorPetId: senderPetId,
              );
              break;
            }
          }
        }
      } catch (_) {}
    } catch (_) {
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
  final List<ChatThreadModel> threads;
  final bool isLoading;
  final String? error;

  ChatState({
    this.threads = const [],
    this.isLoading = false,
    this.error,
  });

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

  @override
  ChatState build() {
    ref.onDispose(() => _messagesChannel?.unsubscribe());
    final activePet = ref.watch(activePetProvider);
    if (activePet != null) {
      _loadThreads(activePet.id);
    }
    return ChatState(isLoading: true);
  }

  Future<void> _loadThreads(String myPetId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final threads = await chatRepository.fetchThreads(myPetId);

      // Fetch all unread counts in a single batch query
      final threadIds = threads.map((t) => t.id).toList();
      final unreadCounts = await chatRepository.fetchUnreadCountsForThreads(
          threadIds, myPetId);
      final threadsWithCounts = threads
          .map((t) => t.copyWith(unreadCount: unreadCounts[t.id] ?? 0))
          .toList();

      state = state.copyWith(threads: threadsWithCounts, isLoading: false);
      _subscribeToIncomingMessages(myPetId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _subscribeToIncomingMessages(String myPetId) {
    _messagesChannel?.unsubscribe();
    final knownThreadIds = state.threads.map((t) => t.id).toSet();

    _messagesChannel = chatRepository.subscribeToAllMessages(
      onMessage: (msg) {
        // Ignore own messages (already added optimistically)
        if (msg.senderPetId == myPetId) return;
        if (!knownThreadIds.contains(msg.threadId)) return;

        state = state.copyWith(
          threads: state.threads.map((t) {
            if (t.id != msg.threadId) return t;
            return t.copyWith(
              lastMessage: msg,
              unreadCount: t.unreadCount + 1,
            );
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
      state = state.copyWith(error: 'Could not start chat: $e');
      return null;
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
