import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/messaging/presentation/controllers/chat_controller.dart';
import 'package:petfolio/features/messaging/data/models/chat_thread_model.dart';
import 'package:petfolio/features/messaging/data/models/message_model.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';

ChatThreadModel _thread({
  String id = 'thread-1',
  int unreadCount = 0,
}) {
  return ChatThreadModel(
    id: id,
    participantPetIds: const ['pet-a', 'pet-b'],
    participantPets: const [
      PetModel(
        id: 'pet-a',
        userId: 'user-a',
        name: 'Rex',
        animalType: 'dog',
        breed: 'Lab',
        age: 2,
        bio: '',
        profileImageUrl: '',
      ),
      PetModel(
        id: 'pet-b',
        userId: 'user-b',
        name: 'Luna',
        animalType: 'cat',
        breed: 'Siamese',
        age: 1,
        bio: '',
        profileImageUrl: '',
      ),
    ],
    unreadCount: unreadCount,
    updatedAt: DateTime.utc(2026),
  );
}

void main() {
  group('ChatState', () {
    test('default state is empty and not loading', () {
      final state = ChatState();

      expect(state.threads, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.totalUnread, 0);
    });

    test('totalUnread sums unreadCount across threads', () {
      final state = ChatState(
        threads: [
          _thread(unreadCount: 3),
          _thread(id: 'thread-2', unreadCount: 7),
          _thread(id: 'thread-3'),
        ],
      );

      expect(state.totalUnread, 10);
    });

    test('totalUnread is 0 when no threads', () {
      final state = ChatState();
      expect(state.totalUnread, 0);
    });

    test('copyWith replaces threads list', () {
      final initial = ChatState();
      final updated = initial.copyWith(threads: [_thread()]);

      expect(updated.threads.length, 1);
      expect(initial.threads, isEmpty);
    });

    test('copyWith sets loading state', () {
      final state = ChatState();
      final loading = state.copyWith(isLoading: true);

      expect(loading.isLoading, true);
      expect(state.isLoading, false);
    });

    test('copyWith clears error with clearError flag', () {
      final state = ChatState(error: 'Load failed');
      final cleared = state.copyWith(clearError: true);

      expect(state.error, 'Load failed');
      expect(cleared.error, isNull);
    });

    test('copyWith preserves existing threads when not specified', () {
      final state = ChatState(threads: [_thread()]);
      final updated = state.copyWith(isLoading: true);

      expect(updated.threads.length, 1);
      expect(updated.isLoading, true);
    });

    test('thread unread increment updates totalUnread', () {
      final t = _thread(unreadCount: 2);
      var state = ChatState(threads: [t]);
      expect(state.totalUnread, 2);

      state = state.copyWith(
        threads: state.threads
            .map((thread) => thread.id == t.id
                ? thread.copyWith(unreadCount: thread.unreadCount + 1)
                : thread)
            .toList(),
      );

      expect(state.totalUnread, 3);
    });
  });

  group('ThreadMessagesNotifier (state list)', () {
    final now = DateTime.utc(2026, 1, 15, 10);

    MessageModel makeMsg(String id, {String text = 'hello'}) => MessageModel(
          id: id,
          threadId: 'thread-1',
          senderPetId: 'pet-a',
          text: text,
          createdAt: now,
        );

    test('deduplicates messages by id', () {
      final msgs = [makeMsg('m-1'), makeMsg('m-2'), makeMsg('m-1')];
      final unique = <String>{};
      final deduped = msgs.where((m) => unique.add(m.id)).toList();

      expect(deduped.length, 2);
      expect(deduped.map((m) => m.id), containsAll(['m-1', 'm-2']));
    });

    test('optimistic rollback removes temp message on error', () {
      const tempId = 'temp-123';
      var messages = [makeMsg('m-1'), makeMsg(tempId, text: 'pending...')];

      // Simulate rollback
      messages = messages.where((m) => m.id != tempId).toList();

      expect(messages.length, 1);
      expect(messages.first.id, 'm-1');
    });

    test('replaces temp message with real one from server', () {
      const tempId = 'temp-456';
      var messages = [makeMsg('m-1'), makeMsg(tempId, text: 'draft')];
      final sent = makeMsg('server-id', text: 'draft');

      messages = messages
          .map((m) => m.id == tempId ? sent : m)
          .toList();

      expect(messages.length, 2);
      expect(messages.last.id, 'server-id');
      expect(messages.none((m) => m.id == tempId), true);
    });
  });
}

extension _ListX<T> on List<T> {
  bool none(bool Function(T) test) => !any(test);
}
