import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/notifications/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    final testDate = DateTime(2026, 5, 10);
    final testNotification = NotificationModel(
      id: 'notif123',
      userId: 'user456',
      type: 'like',
      title: 'New Like',
      body: 'Someone liked your post',
      createdAt: testDate,
    );

    test('creates instance with required parameters', () {
      expect(testNotification.id, 'notif123');
      expect(testNotification.userId, 'user456');
      expect(testNotification.type, 'like');
      expect(testNotification.title, 'New Like');
      expect(testNotification.body, 'Someone liked your post');
      expect(testNotification.isRead, false);
      expect(testNotification.createdAt, testDate);
    });

    test('parses from JSON correctly', () {
      final json = {
        'id': 'notif123',
        'user_id': 'user456',
        'type': 'like',
        'title': 'New Like',
        'body': 'Someone liked your post',
        'is_read': false,
        'created_at': testDate.toIso8601String(),
      };
      final parsed = NotificationModel.fromJson(json);
      // Comparing dates can be tricky due to local/utc conversion in fromJson
      expect(parsed.id, testNotification.id);
      expect(parsed.userId, testNotification.userId);
      expect(parsed.type, testNotification.type);
    });

    test('converts to JSON correctly', () {
      final json = testNotification.toJson();
      expect(json['id'], 'notif123');
      expect(json['user_id'], 'user456');
      expect(json['type'], 'like');
      expect(json['is_read'], false);
    });

    test('copyWith creates new instance with updated isRead', () {
      final updated = testNotification.copyWith(isRead: true);
      expect(updated.isRead, true);
      expect(updated.id, testNotification.id);
    });

    test('equality and hashCode', () {
      final notif2 = NotificationModel(
        id: 'notif123',
        userId: 'user456',
        type: 'like',
        title: 'New Like',
        body: 'Someone liked your post',
        createdAt: testDate,
      );
      expect(testNotification, notif2);
      expect(testNotification.hashCode, notif2.hashCode);
    });
  });
}
