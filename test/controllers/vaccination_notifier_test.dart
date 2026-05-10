import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfolio/features/health/presentation/controllers/vaccination_controller.dart';
import 'package:petfolio/features/care/data/pet_care_repository.dart';
import 'package:petfolio/features/health/data/models/pet_health_models.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/core/constants/app_strings.dart';

class MockPetCareRepository extends Mock implements PetCareRepository {}

void main() {
  late MockPetCareRepository mockPetCareRepository;
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

  final tVaccination = PetVaccination(
    id: 'v1',
    petId: '123',
    vaccineName: 'Rabies',
    status: 'scheduled',
    scheduledFor: DateTime(2026, 6),
  );

  setUpAll(() {
    registerFallbackValue(tVaccination);
  });

  setUp(() {
    mockPetCareRepository = MockPetCareRepository();
    when(() => mockPetCareRepository.fetchVaccinations(any()))
        .thenAnswer((_) async => []);
    
    container = ProviderContainer(
      overrides: [
        petCareRepositoryProvider.overrideWithValue(mockPetCareRepository),
        activePetProvider.overrideWithValue(tPet),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('VaccinationNotifier', () {
    test('initial state should be loading', () {
      final state = container.read(vaccinationProvider);
      expect(state.isLoading, true);
    });

    test('should load vaccinations successfully', () async {
      when(() => mockPetCareRepository.fetchVaccinations('123'))
          .thenAnswer((_) async => [tVaccination]);

      await container.read(vaccinationProvider.notifier).refresh();

      final state = container.read(vaccinationProvider);
      expect(state.vaccinations, [tVaccination]);
      expect(state.isLoading, false);
    });

    test('upsertVaccination should update state on success', () async {
      when(() => mockPetCareRepository.upsertVaccination(any()))
          .thenAnswer((_) async => tVaccination);

      await container.read(vaccinationProvider.notifier).upsertVaccination(tVaccination);

      final state = container.read(vaccinationProvider);
      expect(state.vaccinations.contains(tVaccination), true);
      expect(state.error, isNull);
    });

    test('markComplete should update state on success', () async {
      final completedVax = tVaccination.copyWith(status: 'completed', completedOn: DateTime.now());
      when(() => mockPetCareRepository.markVaccinationComplete(any()))
          .thenAnswer((_) async => completedVax);

      await container.read(vaccinationProvider.notifier).markComplete('v1');

      final state = container.read(vaccinationProvider);
      expect(state.vaccinations.firstWhere((v) => v.id == 'v1').isCompleted, true);
      expect(state.error, isNull);
    });

    test('should set error state when fetch fails', () async {
      when(() => mockPetCareRepository.fetchVaccinations('123'))
          .thenThrow(Exception('Fetch error'));

      await container.read(vaccinationProvider.notifier).refresh();

      final state = container.read(vaccinationProvider);
      expect(state.error, AppStrings.healthLoadFailed);
      expect(state.isLoading, false);
    });
  });
}
