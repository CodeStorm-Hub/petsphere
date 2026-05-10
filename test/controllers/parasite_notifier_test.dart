import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petsphere/features/health/presentation/controllers/parasite_controller.dart';
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

  final tParasite = ParasitePrevention(
    id: 'p1',
    petId: '123',
    productName: 'NexGard',
    productType: 'flea_tick',
    administeredOn: DateTime(2026),
    nextDueDate: DateTime(2026, 2),
  );

  setUpAll(() {
    registerFallbackValue(tParasite);
  });

  setUp(() {
    mockHealthRepository = MockHealthRepository();
    when(() => mockHealthRepository.fetchParasitePrevention(any()))
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

  group('ParasiteNotifier', () {
    test('initial state should be loading', () {
      final state = container.read(parasiteProvider);
      expect(state.isLoading, true);
    });

    test('should load parasite prevention entries successfully', () async {
      when(() => mockHealthRepository.fetchParasitePrevention('123'))
          .thenAnswer((_) async => [tParasite]);

      await container.read(parasiteProvider.notifier).refresh();

      final state = container.read(parasiteProvider);
      expect(state.entries, [tParasite]);
      expect(state.isLoading, false);
    });

    test('logTreatment should add to state on success', () async {
      when(() => mockHealthRepository.logParasiteTreatment(any()))
          .thenAnswer((_) async => tParasite);

      await container.read(parasiteProvider.notifier).logTreatment(tParasite);

      final state = container.read(parasiteProvider);
      expect(state.entries.contains(tParasite), true);
      expect(state.error, isNull);
    });

    test('deleteEntry should remove from state immediately (optimistic)', () async {
      when(() => mockHealthRepository.fetchParasitePrevention('123'))
          .thenAnswer((_) async => [tParasite]);
      when(() => mockHealthRepository.deleteParasiteEntry(any()))
          .thenAnswer((_) async => {});

      await container.read(parasiteProvider.notifier).refresh();
      
      final deleteFuture = container.read(parasiteProvider.notifier).deleteEntry('p1');
      
      // Check optimistic removal
      expect(container.read(parasiteProvider).entries.isEmpty, true);
      
      await deleteFuture;
      expect(container.read(parasiteProvider).error, isNull);
    });

    test('should set error state when fetch fails', () async {
      when(() => mockHealthRepository.fetchParasitePrevention('123'))
          .thenThrow(Exception('Fetch error'));

      await container.read(parasiteProvider.notifier).refresh();

      final state = container.read(parasiteProvider);
      expect(state.error, AppStrings.healthLoadFailed);
      expect(state.isLoading, false);
    });
  });
}
