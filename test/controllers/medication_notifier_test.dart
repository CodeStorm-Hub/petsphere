import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petsphere/features/health/presentation/controllers/medication_controller.dart';
import 'package:petsphere/features/health/data/health_repository.dart';
import 'package:petsphere/features/health/data/models/pet_health_extended_models.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petsphere/features/pet/data/models/pet_model.dart';

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

  final tMedication = PetMedication(
    id: 'm1',
    petId: '123',
    name: 'Apoquel',
    frequency: 'once_daily',
    startDate: DateTime(2026),
    status: 'active',
  );

  final tDose = MedicationDose(
    id: 'd1',
    medicationId: 'm1',
    petId: '123',
    scheduledFor: DateTime(2026, 1, 1, 8),
    skipped: false,
  );

  setUpAll(() {
    registerFallbackValue(tMedication);
    registerFallbackValue(tDose);
  });

  setUp(() {
    mockHealthRepository = MockHealthRepository();
  });

  tearDown(() {
    container.dispose();
  });

  group('MedicationNotifier', () {
    test('should load medications and doses successfully', () async {
      when(() => mockHealthRepository.fetchMedications('123'))
          .thenAnswer((_) async => [tMedication]);
      when(() => mockHealthRepository.fetchTodayDoses('123'))
          .thenAnswer((_) async => [tDose]);

      container = ProviderContainer(
        overrides: [
          healthRepositoryProvider.overrideWithValue(mockHealthRepository),
          activePetProvider.overrideWithValue(tPet),
        ],
      );

      // Trigger load
      await container.read(medicationProvider.notifier).refresh();

      final state = container.read(medicationProvider);
      expect(state.medications.any((m) => m.id == 'm1'), true);
      expect(state.todayDoses.any((d) => d.id == 'd1'), true);
    });

    test('addMedication should update state on success', () async {
      when(() => mockHealthRepository.fetchMedications(any())).thenAnswer((_) async => []);
      when(() => mockHealthRepository.fetchTodayDoses(any())).thenAnswer((_) async => []);
      when(() => mockHealthRepository.upsertMedication(any())).thenAnswer((_) async => tMedication);
      when(() => mockHealthRepository.generateDosesIdempotent(any())).thenAnswer((_) async => {});

      container = ProviderContainer(
        overrides: [
          healthRepositoryProvider.overrideWithValue(mockHealthRepository),
          activePetProvider.overrideWithValue(tPet),
        ],
      );

      // Wait for initialization
      await container.read(medicationProvider.notifier).refresh();

      await container.read(medicationProvider.notifier).addMedication(tMedication);

      final state = container.read(medicationProvider);
      expect(state.medications.any((m) => m.id == 'm1'), true);
      expect(state.error, isNull);
    });
  });
}
