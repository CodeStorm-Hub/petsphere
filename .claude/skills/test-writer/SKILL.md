---
name: test-writer
description: Generate unit tests for Notifiers and business logic following PetSphere patterns
user-invocable: true
disable-model-invocation: false
---

# Test Writer for PetSphere

Generate comprehensive unit tests for your controllers, repositories, and models following the project's arrange-act-assert pattern and Riverpod testing conventions.

## Usage

```
/test-writer lib/controllers/pet_controller.dart
/test-writer lib/repositories/health_repository.dart --coverage
```

## Parameters

- **File Path** (required): Path to the file you want to test (controller, repository, or utility)
- `--coverage`: Include assertions to improve code coverage
- `--mocks`: Generate mock objects for dependencies
- `--integration`: Create integration tests instead of unit tests

## Generated Pattern

Tests follow arrange-act-assert with Riverpod testing setup:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:petsphere/controllers/pet_controller.dart';

void main() {
  group('PetNotifier', () {
    late PetNotifier notifier;
    late MockPetRepository mockRepository;

    setUp(() {
      mockRepository = MockPetRepository();
      notifier = PetNotifier(mockRepository);
    });

    test('loadPets updates state with fetched pets', () async {
      // Arrange
      final testPets = [
        PetModel(id: '1', userId: 'user1', name: 'Fluffy'),
        PetModel(id: '2', userId: 'user1', name: 'Spot'),
      ];
      when(mockRepository.fetchMyPets('user1'))
          .thenAnswer((_) async => testPets);

      // Act
      await notifier.loadPets('user1');

      // Assert
      expect(notifier.state.myPets.length, 2);
      expect(notifier.state.myPets[0].name, 'Fluffy');
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('loadPets sets error state on exception', () async {
      // Arrange
      when(mockRepository.fetchMyPets('user1'))
          .thenThrow(Exception('Network error'));

      // Act
      await notifier.loadPets('user1');

      // Assert
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.isLoading, false);
    });
  });
}
```

## Coverage Goals

Tests generated include:
- ✅ Happy path (successful operations)
- ✅ Error paths (exception handling)
- ✅ State transitions (loading → loaded → error)
- ✅ Edge cases (empty lists, null values)
- ✅ Repository interactions (verify calls with mocks)

## Tips

- Each notifier method gets 2-3 test cases (success + error + edge case)
- Use `mockito` for mocking repositories
- Test state transitions, not implementation details
- Avoid testing Riverpod framework code; focus on your logic
- Run with `flutter test --coverage` to measure coverage

## File Structure

Generated tests are placed in `test/controllers/`, `test/repositories/`, etc., mirroring your `lib/` structure.
