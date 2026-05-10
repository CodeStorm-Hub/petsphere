import 'package:flutter_test/flutter_test.dart';
import 'package:petsphere/features/pet/data/models/pet_model.dart';

void main() {
  group('PetModel', () {
    test('creates instance with required parameters', () {
      const pet = PetModel(
        id: 'pet-123',
        userId: 'user-456',
        name: 'Fluffy',
        animalType: 'dog',
        breed: 'Golden Retriever',
        age: 3,
        bio: 'A friendly dog',
        profileImageUrl: 'https://example.com/image.jpg',
      );

      expect(pet.id, 'pet-123');
      expect(pet.userId, 'user-456');
      expect(pet.name, 'Fluffy');
      expect(pet.animalType, 'dog');
      expect(pet.breed, 'Golden Retriever');
      expect(pet.age, 3);
      expect(pet.bio, 'A friendly dog');
    });

    test('parses from JSON correctly', () {
      final json = {
        'id': 'pet-123',
        'user_id': 'user-456',
        'name': 'Fluffy',
        'animal_type': 'dog',
        'breed': 'Golden Retriever',
        'age': 3,
        'bio': 'A friendly dog',
        'profile_image_url': 'https://example.com/image.jpg',
        'images': ['image1.jpg', 'image2.jpg'],
        'weight_lbs': 65.5,
        'daily_calorie_goal': 1500,
        'daily_water_goal_cups': 8,
        'is_public_owner': true,
        'is_verified': false,
        'monthly_budget': 500.0,
      };

      final pet = PetModel.fromJson(json);

      expect(pet.id, 'pet-123');
      expect(pet.userId, 'user-456');
      expect(pet.name, 'Fluffy');
      expect(pet.animalType, 'dog');
      expect(pet.breed, 'Golden Retriever');
      expect(pet.age, 3);
      expect(pet.bio, 'A friendly dog');
      expect(pet.profileImageUrl, 'https://example.com/image.jpg');
      expect(pet.weightLbs, 65.5);
      expect(pet.dailyCalorieGoal, 1500);
      expect(pet.isPublicOwner, true);
      expect(pet.isVerified, false);
    });

    test('converts to JSON correctly', () {
      const pet = PetModel(
        id: 'pet-123',
        userId: 'user-456',
        name: 'Fluffy',
        animalType: 'dog',
        breed: 'Golden Retriever',
        age: 3,
        bio: 'A friendly dog',
        profileImageUrl: 'https://example.com/image.jpg',
        weightLbs: 65.5,
        dailyCalorieGoal: 1500,
      );

      final json = pet.toJson();

      // Note: toJson() doesn't include 'id', only user-facing fields
      expect(json['user_id'], 'user-456');
      expect(json['name'], 'Fluffy');
      expect(json['animal_type'], 'dog');
      expect(json['breed'], 'Golden Retriever');
      expect(json['age'], 3);
      expect(json['bio'], 'A friendly dog');
      expect(json['daily_calorie_goal'], 1500);
    });

    test('copyWith creates new instance with updated fields', () {
      const pet = PetModel(
        id: 'pet-123',
        userId: 'user-456',
        name: 'Fluffy',
        animalType: 'dog',
        breed: 'Golden Retriever',
        age: 3,
        bio: 'A friendly dog',
        profileImageUrl: 'https://example.com/image.jpg',
      );

      final updated = pet.copyWith(name: 'Fluffy Jr.', age: 2);

      expect(updated.id, 'pet-123');
      expect(updated.userId, 'user-456');
      expect(updated.name, 'Fluffy Jr.');
      expect(updated.age, 2);
      expect(updated.breed, 'Golden Retriever');
      expect(pet.name, 'Fluffy'); // Original unchanged
    });

    test('parses JSON with minimal required fields', () {
      final json = {
        'id': 'pet-123',
        'user_id': 'user-456',
        'name': 'Fluffy',
        'animal_type': 'dog',
        'breed': 'Golden Retriever',
        'age': 3,
        'bio': 'A friendly dog',
        'profile_image_url': 'https://example.com/image.jpg',
      };

      final pet = PetModel.fromJson(json);

      expect(pet.id, 'pet-123');
      expect(pet.userId, 'user-456');
      expect(pet.name, 'Fluffy');
      expect(pet.dailyCalorieGoal, null);
      expect(pet.weightLbs, null);
    });

    test('handles null optional fields', () {
      final json = {
        'id': 'pet-123',
        'user_id': 'user-456',
        'name': 'Fluffy',
        'animal_type': 'dog',
        'breed': 'Golden Retriever',
        'age': 3,
        'bio': 'A friendly dog',
        'profile_image_url': 'https://example.com/image.jpg',
      };

      final pet = PetModel.fromJson(json);

      expect(pet.dailyCalorieGoal, null);
      expect(pet.dailyWaterGoalCups, null);
      expect(pet.weightLbs, null);
      expect(pet.monthlyBudget, 1000.0); // Default value
    });

    test('instances with same data are equal (value equality)', () {
      const pet1 = PetModel(
        id: 'pet-123',
        userId: 'user-456',
        name: 'Fluffy',
        animalType: 'dog',
        breed: 'Golden Retriever',
        age: 3,
        bio: 'A friendly dog',
        profileImageUrl: 'https://example.com/image.jpg',
      );

      const pet2 = PetModel(
        id: 'pet-123',
        userId: 'user-456',
        name: 'Fluffy',
        animalType: 'dog',
        breed: 'Golden Retriever',
        age: 3,
        bio: 'A friendly dog',
        profileImageUrl: 'https://example.com/image.jpg',
      );

      // PetModel overrides == for value equality
      expect(pet1, equals(pet2));
      expect(identical(pet1, pet2), isTrue); // Because they are const
    });

    test('copyWith preserves all fields except overridden ones', () {
      const original = PetModel(
        id: 'pet-123',
        userId: 'user-456',
        name: 'Fluffy',
        animalType: 'dog',
        breed: 'Golden Retriever',
        age: 3,
        bio: 'A friendly dog',
        profileImageUrl: 'https://example.com/image.jpg',
        dailyCalorieGoal: 1500,
        monthlyBudget: 500.0,
      );

      final updated = original.copyWith(name: 'Fluffy Jr.');

      expect(updated.name, 'Fluffy Jr.');
      expect(updated.dailyCalorieGoal, 1500);
      expect(updated.monthlyBudget, 500.0);
    });
  });
}
