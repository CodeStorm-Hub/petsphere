import 'package:flutter_test/flutter_test.dart';
import 'package:pet_dating_app/models/pet_model.dart';

void main() {
  group('PetModel', () {
    test('fromJson applies defaults for optional fields', () {
      final pet = PetModel.fromJson({
        'id': 'pet-1',
        'user_id': 'user-1',
        'name': 'Mochi',
        'breed': 'Shiba',
        'animal_type': 'dog',
        'age': 5,
        // bio/profile_image_url/images/is_public_owner intentionally omitted
      });

      expect(pet.id, 'pet-1');
      expect(pet.userId, 'user-1');
      expect(pet.name, 'Mochi');
      expect(pet.breed, 'Shiba');
      expect(pet.animalType, 'dog');
      expect(pet.age, 5);
      expect(pet.bio, '');
      expect(pet.profileImageUrl, '');
      expect(pet.images, isEmpty);
      expect(pet.isPublicOwner, isTrue);
    });

    test('toJson matches expected API column keys', () {
      final pet = PetModel(
        id: 'pet-1',
        userId: 'user-1',
        name: 'Mochi',
        breed: 'Shiba',
        animalType: 'dog',
        age: 5,
        bio: 'Very polite',
        profileImageUrl: 'https://example.com/pet.png',
        images: const ['https://example.com/pet.png'],
        isPublicOwner: false,
      );

      expect(pet.toJson(), {
        'user_id': 'user-1',
        'name': 'Mochi',
        'breed': 'Shiba',
        'animal_type': 'dog',
        'age': 5,
        'bio': 'Very polite',
        'profile_image_url': 'https://example.com/pet.png',
        'images': const ['https://example.com/pet.png'],
        'is_public_owner': false,
      });
    });
  });
}
