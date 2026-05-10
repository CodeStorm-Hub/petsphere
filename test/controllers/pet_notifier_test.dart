import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/pet/data/pet_repository.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

import '../helpers/mock_repositories.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────────────────

PetModel _makePet({
  String id = 'pet-1',
  String userId = 'user-1',
  String name = 'Buddy',
}) =>
    PetModel(
      id: id,
      userId: userId,
      name: name,
      breed: 'Golden Retriever',
      animalType: 'dog',
      age: 3,
      bio: 'A friendly dog',
      profileImageUrl: '',
    );

// ──────────────────────────────────────────────────────────────────────────────
// Tests
// ──────────────────────────────────────────────────────────────────────────────

void main() {
  late MockPetRepository mockRepo;

  setUp(() {
    mockRepo = MockPetRepository();
  });

  // ---------------------------------------------------------------------------
  group('PetState', () {
    test('initial state has correct defaults', () {
      final state = PetState();
      expect(state.myPets, isEmpty);
      expect(state.activePet, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.hasNoPets, isTrue);
    });

    test('copyWith preserves unchanged fields', () {
      final original = PetState(myPets: [_makePet()]);
      final updated = original.copyWith(isLoading: true);

      expect(updated.myPets, same(original.myPets));
      expect(updated.isLoading, isTrue);
      expect(updated.error, isNull);
    });

    test('copyWith clearError resets error to null', () {
      final withError = PetState(error: 'Something went wrong');
      final cleared = withError.copyWith(clearError: true);

      expect(cleared.error, isNull);
    });

    test('hasNoPets is false when loading', () {
      final state = PetState(isLoading: true);
      expect(state.hasNoPets, isFalse);
    });

    test('hasNoPets is false when pets exist', () {
      final state = PetState(myPets: [_makePet()]);
      expect(state.hasNoPets, isFalse);
    });

    test('hasNoPets is true when empty and not loading', () {
      expect(PetState().hasNoPets, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  group('PetNotifier.setActivePet', () {
    test('updates activePet without changing myPets list', () {
      final container = ProviderContainer(
        overrides: [petRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final pet1 = _makePet();
      final pet2 = _makePet(id: 'pet-2', name: 'Max');

      final notifier = container.read(petProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = PetState(myPets: [pet1, pet2], activePet: pet1);

      notifier.setActivePet(pet2);

      expect(container.read(petProvider).activePet?.id, 'pet-2');
      expect(container.read(petProvider).myPets.length, 2);
    });

    test('switches between multiple pets correctly', () {
      final container = ProviderContainer(
        overrides: [petRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final pets = List.generate(
        5,
        (i) => _makePet(id: 'pet-$i', name: 'Pet $i'),
      );

      final notifier = container.read(petProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = PetState(myPets: pets, activePet: pets.first);

      notifier.setActivePet(pets.last);
      expect(container.read(petProvider).activePet?.id, 'pet-4');

      notifier.setActivePet(pets[2]);
      expect(container.read(petProvider).activePet?.id, 'pet-2');
    });
  });

  // ---------------------------------------------------------------------------
  group('PetModel serialization', () {
    test('fromJson roundtrip preserves all required fields', () {
      final json = {
        'id': 'pet-abc',
        'user_id': 'user-xyz',
        'name': 'Luna',
        'breed': 'Siamese',
        'animal_type': 'cat',
        'age': 2,
        'bio': 'A quiet cat',
        'profile_image_url': 'https://example.com/luna.jpg',
        'is_public_owner': true,
        'is_breeding_listed': false,
        'created_at': '2026-01-01T00:00:00.000Z',
        'monthly_budget': 150.0,
      };

      final model = PetModel.fromJson(json);

      expect(model.id, 'pet-abc');
      expect(model.userId, 'user-xyz');
      expect(model.name, 'Luna');
      expect(model.breed, 'Siamese');
      expect(model.animalType, 'cat');
      expect(model.age, 2);
      expect(model.bio, 'A quiet cat');
      expect(model.profileImageUrl, 'https://example.com/luna.jpg');
    });

    test('toJson produces expected keys', () {
      final model = _makePet();
      final json = model.toJson();

      expect(json, containsPair('id', 'pet-1'));
      expect(json, containsPair('user_id', 'user-1'));
      expect(json, containsPair('name', 'Buddy'));
      expect(json.containsKey('animal_type'), isTrue);
    });

    test('copyWith does not mutate original', () {
      final original = _makePet();
      final copy = original.copyWith(name: 'Max');

      expect(original.name, 'Buddy');
      expect(copy.name, 'Max');
      expect(copy.id, original.id);
      expect(copy.userId, original.userId);
    });

    test('fromJson handles null optional fields gracefully', () {
      final json = {
        'id': 'pet-xyz',
        'user_id': 'user-1',
        'name': 'Sparky',
        'breed': 'Mutt',
        'animal_type': 'dog',
        'age': 1,
        'bio': '',
        'profile_image_url': '',
      };

      final model = PetModel.fromJson(json);
      expect(model.name, 'Sparky');
      expect(model.profileImageUrl, '');
    });
  });

  // ---------------------------------------------------------------------------
  group('breedSuggestionsProvider', () {
    test('returns empty list for query shorter than 2 chars', () async {
      final container = ProviderContainer(
        overrides: [petRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(breedSuggestionsProvider('a').future);
      expect(result, isEmpty);
      verifyNever(() => mockRepo.fetchBreedSuggestions(any()));
    });

    test('returns empty list for empty string', () async {
      final container = ProviderContainer(
        overrides: [petRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(breedSuggestionsProvider('').future);
      expect(result, isEmpty);
      verifyNever(() => mockRepo.fetchBreedSuggestions(any()));
    });

    test('calls repo for queries of 2+ chars', () async {
      when(
        () => mockRepo.fetchBreedSuggestions(
          any(),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ['Retriever', 'Rex']);

      final container = ProviderContainer(
        overrides: [petRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(breedSuggestionsProvider('re').future);
      expect(result, contains('Retriever'));
    });
  });

  // ---------------------------------------------------------------------------
  group('ProfilePetNavigation', () {
    test('navigateTo sets state and clear resets it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profilePetNavigationProvider.notifier);
      expect(container.read(profilePetNavigationProvider), isNull);

      notifier.navigateTo('pet-123');
      expect(container.read(profilePetNavigationProvider), 'pet-123');

      notifier.clear();
      expect(container.read(profilePetNavigationProvider), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  group('MainLayoutTabRequest', () {
    test('request sets tab index and clear resets it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(mainLayoutTabRequestProvider.notifier);
      expect(container.read(mainLayoutTabRequestProvider), isNull);

      notifier.request(3);
      expect(container.read(mainLayoutTabRequestProvider), 3);

      notifier.clear();
      expect(container.read(mainLayoutTabRequestProvider), isNull);
    });
  });
}
