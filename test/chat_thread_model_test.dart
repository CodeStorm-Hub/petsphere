import 'package:flutter_test/flutter_test.dart';
import 'package:pet_dating_app/models/chat_thread_model.dart';

void main() {
  group('ChatThreadModel.fromJson', () {
    test('parses with updated_at when present', () {
      final t = ChatThreadModel.fromJson({
        'id': 'thread-1',
        'pet_id_1': 'pet-a',
        'pet_id_2': 'pet-b',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-04-01T12:30:00Z',
        'pet1': null,
        'pet2': null,
      });

      expect(t.id, 'thread-1');
      expect(t.participantPetIds, ['pet-a', 'pet-b']);
      expect(t.updatedAt.toUtc().year, 2026);
      expect(t.updatedAt.toUtc().month, 4);
    });

    test('falls back gracefully when updated_at is missing', () {
      // This documents the legacy behavior — the repository now sends updated_at,
      // but the model must still tolerate older payloads.
      final t = ChatThreadModel.fromJson({
        'id': 'thread-2',
        'pet_id_1': 'pet-a',
        'pet_id_2': 'pet-b',
        'pet1': null,
        'pet2': null,
      });

      expect(t.id, 'thread-2');
      expect(t.updatedAt, isA<DateTime>());
    });
  });
}
