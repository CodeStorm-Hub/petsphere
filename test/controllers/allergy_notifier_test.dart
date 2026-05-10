import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petsphere/features/health/presentation/controllers/allergy_controller.dart';
import 'package:petsphere/features/health/data/health_repository.dart';
import 'package:petsphere/features/health/data/models/pet_health_extended_models.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petsphere/features/pet/data/models/pet_model.dart';
import 'package:petsphere/core/constants/app_strings.dart';

class MockHealthRepository extends Mock implements HealthRepository {}

void main() {
  late MockHealthRepository mockHealthRepository;
  late ProviderContainer container;

  const tPet = PetModel(
    id: '123',
    userId: 'user123',
    name: 'Buddy',
    breed: 'Golden Retriever',
    animalType: 'Dog',
    age: 3,
    bio: 'A happy dog',
    profileImageUrl: '',
  );

  const tAllergy = PetAllergy(
    id: 'a1',
    petId: '123',
    allergen: 'Pollen',
    allergenType: 'environmental',
    severity: 'mild',
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(tAllergy);
  });

  setUp(() {
    mockHealthRepository = MockHealthRepository();
    // Default mock behavior to avoid unhandled stub exceptions
    when(() => mockHealthRepository.fetchAllergies(any()))
        .thenAnswer((_) async => []);
    
    container = ProviderContainer(
      overrides: [
        healthRepositoryProvider.overrideWithValue(mockHealthRepository),
        activePetProvider.overrideWithValue(tPet),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AllergyNotifier', () {
    test('initial state should be loading when petId exists', () {
      final state = container.read(allergyProvider);
      expect(state.isLoading, true);
    });

    test('should load allergies successfully', () async {
      when(() => mockHealthRepository.fetchAllergies('123'))
          .thenAnswer((_) async => [tAllergy]);

      // Wait for the microtask in build() to complete
      await container.read(allergyProvider.notifier).refresh();

      final state = container.read(allergyProvider);
      expect(state.allergies, [tAllergy]);
      expect(state.isLoading, false);
    });

    test('addAllergy should add to state on success', () async {
      when(() => mockHealthRepository.insertAllergy(any()))
          .thenAnswer((_) async => tAllergy);

      await container.read(allergyProvider.notifier).addAllergy(tAllergy);

      final state = container.read(allergyProvider);
      expect(state.allergies.contains(tAllergy), true);
      expect(state.error, isNull);
    });

    test('removeAllergy should remove from state immediately (optimistic)', () async {
      when(() => mockHealthRepository.fetchAllergies('123'))
          .thenAnswer((_) async => [tAllergy]);
      when(() => mockHealthRepository.deleteAllergy(any()))
          .thenAnswer((_) async => {});

      await container.read(allergyProvider.notifier).refresh();
      
      final removeFuture = container.read(allergyProvider.notifier).removeAllergy('a1');
      
      // Check optimistic removal
      expect(container.read(allergyProvider).allergies.isEmpty, true);
      
      await removeFuture;
      expect(container.read(allergyProvider).error, isNull);
    });

    test('should set error state when fetch fails', () async {
      when(() => mockHealthRepository.fetchAllergies('123'))
          .thenThrow(Exception('Fetch error'));

      await container.read(allergyProvider.notifier).refresh();

      final state = container.read(allergyProvider);
      expect(state.error, AppStrings.healthLoadFailed);
      expect(state.isLoading, false);
    });
  });
}
