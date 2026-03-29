import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_thread_model.dart';
import '../models/message_model.dart';
import 'feed_controller.dart'; // Source of mockPets

class ChatState {
  final List<ChatThreadModel> threads;
  final Map<String, List<MessageModel>> messages; // Keyed by threadId

  ChatState({
    this.threads = const [],
    this.messages = const {},
  });

  ChatState copyWith({
    List<ChatThreadModel>? threads,
    Map<String, List<MessageModel>>? messages,
  }) {
    return ChatState(
      threads: threads ?? this.threads,
      messages: messages ?? this.messages,
    );
  }
}

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() {
    // Current Pet is mockPets[0] (Bella)
    final thread1Id = 'thread-1';
    
    // Seed an initial mock thread (Bella and Max are matched)
    final mockThread = ChatThreadModel(
      id: thread1Id,
      participantPetIds: ['pet-1', 'pet-2'],
      participantPets: [mockPets[0], mockPets[1]], // Bella and Max
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 1,
      lastMessage: MessageModel(
        id: 'msg-1',
        threadId: thread1Id,
        senderPetId: 'pet-2',
        text: 'Hi Bella! Max would love to meet up.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    );

    final mockMessages = {
      thread1Id: [
        mockThread.lastMessage!,
      ]
    };

    return ChatState(threads: [mockThread], messages: mockMessages);
  }

  void sendMessage(String threadId, String senderPetId, String text) {
    if (text.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      threadId: threadId,
      senderPetId: senderPetId,
      text: text.trim(),
      createdAt: DateTime.now(),
      isRead: true, // Auto-read for the sender obviously
    );

    final updatedMessages = Map<String, List<MessageModel>>.from(state.messages);
    if (!updatedMessages.containsKey(threadId)) {
      updatedMessages[threadId] = [];
    }
    updatedMessages[threadId] = [...updatedMessages[threadId]!, newMessage];

    final updatedThreads = state.threads.map((thread) {
      if (thread.id == threadId) {
        return thread.copyWith(
          lastMessage: newMessage,
          updatedAt: newMessage.createdAt,
          // If we are sending it, unread count logic for us doesn't increment.
        );
      }
      return thread;
    }).toList();

    // Sort threads by most recent
    updatedThreads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    state = state.copyWith(messages: updatedMessages, threads: updatedThreads);
  }

  void markThreadAsRead(String threadId) {
    state = state.copyWith(
      threads: state.threads.map((thread) {
        if (thread.id == threadId) {
          return thread.copyWith(unreadCount: 0);
        }
        return thread;
      }).toList(),
    );
  }
}

final chatProvider = NotifierProvider<ChatController, ChatState>(() {
  return ChatController();
});
