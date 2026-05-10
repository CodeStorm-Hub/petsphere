import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfolio/features/health/presentation/controllers/dental_controller.dart';
import 'package:petfolio/features/health/data/health_repository.dart';
import 'package:petfolio/features/health/data/models/pet_health_extended_models.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/core/constants/app_strings.dart';

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

  final tDental = DentalLog(
    id: 'd1',
    petId: '123',
    logDate: DateTime(2026),
    cleaningType: 'home_brushing',
  );

  setUpAll(() {
    registerFallbackValue(tDental);
  });

  setUp(() {
    mockHealthRepository = MockHealthRepository();
    when(() => mockHealthRepository.fetchDentalLogs(any()))
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

  group('DentalNotifier', () {
    test('initial state should be loading', () {
      final state = container.read(dentalProvider);
      expect(state.isLoading, true);
    });

    test('should load dental logs successfully', () async {
      when(() => mockHealthRepository.fetchDentalLogs('123'))
          .thenAnswer((_) async => [tDental]);

      await container.read(dentalProvider.notifier).refresh();

      final state = container.read(dentalProvider);
      expect(state.logs, [tDental]);
      expect(state.isLoading, false);
    });

    test('logDental should add to state on success', () async {
      when(() => mockHealthRepository.logDental(any()))
          .thenAnswer((_) async => tDental);

      await container.read(dentalProvider.notifier).logDental(tDental);

      final state = container.read(dentalProvider);
      expect(state.logs.contains(tDental), true);
      expect(state.error, isNull);
    });

    test('deleteDentalLog should remove from state immediately (optimistic)', () async {
      when(() => mockHealthRepository.fetchDentalLogs('123'))
          .thenAnswer((_) async => [tDental]);
      when(() => mockHealthRepository.deleteDentalLog(any()))
          .thenAnswer((_) async => {});

      await container.read(dentalProvider.notifier).refresh();
      
      final deleteFuture = container.read(dentalProvider.notifier).deleteDentalLog('d1');
      
      // Check optimistic removal
      expect(container.read(dentalProvider).logs.isEmpty, true);
      
      await deleteFuture;
      expect(container.read(dentalProvider).error, isNull);
    });

    test('should set error state when fetch fails', () async {
      when(() => mockHealthRepository.fetchDentalLogs('123'))
          .thenThrow(Exception('Fetch error'));

      await container.read(dentalProvider.notifier).refresh();

      final state = container.read(dentalProvider);
      expect(state.error, AppStrings.healthLoadFailed);
      expect(state.isLoading, false);
    });
  });
}
