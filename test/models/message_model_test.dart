import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/messaging/data/models/message_model.dart';

void main() {
  final testDate = DateTime.utc(2026, 1, 15, 10, 30);

  group('MessageModel', () {
    test('constructs with required fields', () {
      final msg = MessageModel(
        id: 'msg-1',
        threadId: 'thread-1',
        senderPetId: 'pet-1',
        text: 'Hello!',
        createdAt: testDate,
      );

      expect(msg.id, 'msg-1');
      expect(msg.threadId, 'thread-1');
      expect(msg.senderPetId, 'pet-1');
      expect(msg.text, 'Hello!');
      expect(msg.isRead, false);
    });

    test('fromJson deserializes all fields', () {
      final json = {
        'id': 'msg-2',
        'thread_id': 'thread-2',
        'sender_pet_id': 'pet-2',
        'text': 'Hey there',
        'created_at': testDate.toIso8601String(),
        'is_read': true,
      };

      final msg = MessageModel.fromJson(json);

      expect(msg.id, 'msg-2');
      expect(msg.threadId, 'thread-2');
      expect(msg.senderPetId, 'pet-2');
      expect(msg.text, 'Hey there');
      expect(msg.isRead, true);
    });

    test('fromJson defaults isRead to false when absent', () {
      final json = {
        'id': 'msg-3',
        'thread_id': 'thread-1',
        'sender_pet_id': 'pet-1',
        'text': 'Hi',
        'created_at': testDate.toIso8601String(),
      };

      final msg = MessageModel.fromJson(json);
      expect(msg.isRead, false);
    });

    test('toJson excludes id (server assigns it on insert)', () {
      final msg = MessageModel(
        id: 'msg-1',
        threadId: 'thread-1',
        senderPetId: 'pet-1',
        text: 'Test',
        createdAt: testDate,
      );

      final json = msg.toJson();

      expect(json.containsKey('id'), false);
      expect(json['thread_id'], 'thread-1');
      expect(json['sender_pet_id'], 'pet-1');
      expect(json['text'], 'Test');
      expect(json['is_read'], false);
    });

    test('copyWith updates specific fields', () {
      final original = MessageModel(
        id: 'msg-1',
        threadId: 'thread-1',
        senderPetId: 'pet-1',
        text: 'Original',
        createdAt: testDate,
      );

      final updated = original.copyWith(text: 'Updated', isRead: true);

      expect(updated.text, 'Updated');
      expect(updated.isRead, true);
      expect(updated.id, 'msg-1');
      expect(original.text, 'Original'); // immutable
    });

    test('equality is value-based', () {
      final msg1 = MessageModel(
        id: 'msg-1',
        threadId: 'thread-1',
        senderPetId: 'pet-1',
        text: 'Same',
        createdAt: testDate,
      );
      final msg2 = MessageModel(
        id: 'msg-1',
        threadId: 'thread-1',
        senderPetId: 'pet-1',
        text: 'Same',
        createdAt: testDate,
      );

      expect(msg1, equals(msg2));
    });

    test('different ids are not equal', () {
      final msg1 = MessageModel(
        id: 'msg-1',
        threadId: 'thread-1',
        senderPetId: 'pet-1',
        text: 'Same',
        createdAt: testDate,
      );
      final msg2 = msg1.copyWith(id: 'msg-2');

      expect(msg1, isNot(equals(msg2)));
    });
  });
}
