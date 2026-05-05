import 'package:flutter_test/flutter_test.dart';
import 'package:pet_dating_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('creates instance with required parameters', () {
      final user = UserModel(
        id: 'user-123',
        email: 'test@example.com',
        name: 'John Doe',
      );

      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'John Doe');
    });

    test('parses from JSON correctly', () {
      final json = {
        'id': 'user-123',
        'email': 'test@example.com',
        'name': 'John Doe',
        'bio': 'Pet lover',
        'location': 'San Francisco',
        'profile_image_url': 'https://example.com/avatar.jpg',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'John Doe');
      expect(user.bio, 'Pet lover');
      expect(user.location, 'San Francisco');
      expect(user.profileImageUrl, 'https://example.com/avatar.jpg');
    });

    test('converts to JSON correctly', () {
      final user = UserModel(
        id: 'user-123',
        email: 'test@example.com',
        name: 'John Doe',
        bio: 'Pet lover',
        profileImageUrl: 'https://example.com/avatar.jpg',
      );

      final json = user.toJson();

      expect(json['id'], 'user-123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'John Doe');
      expect(json['bio'], 'Pet lover');
    });

    test('copyWith creates new instance with updated fields', () {
      final user = UserModel(
        id: 'user-123',
        email: 'test@example.com',
        name: 'John Doe',
      );

      final updated = user.copyWith(
        name: 'Jane Doe',
        bio: 'Cat lover',
      );

      expect(updated.id, 'user-123');
      expect(updated.email, 'test@example.com');
      expect(updated.name, 'Jane Doe');
      expect(updated.bio, 'Cat lover');
      expect(user.name, 'John Doe'); // Original unchanged
    });

    test('roundtrip JSON serialization/deserialization', () {
      final original = UserModel(
        id: 'user-123',
        email: 'test@example.com',
        name: 'John Doe',
        bio: 'Pet lover',
        profileImageUrl: 'https://example.com/avatar.jpg',
      );

      final json = original.toJson();
      final deserialized = UserModel.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.email, original.email);
      expect(deserialized.name, original.name);
      expect(deserialized.bio, original.bio);
    });
  });
}
