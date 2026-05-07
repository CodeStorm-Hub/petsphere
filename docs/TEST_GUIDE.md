# Testing Guide

This guide covers how to write, run, and maintain tests in PetSphere.

## Quick Start

### Run All Tests

```bash
flutter test
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

View coverage report:
```bash
# macOS
open coverage/index.html

# Windows/Linux
# Open coverage/index.html in your browser
```

### Run Specific Test File

```bash
flutter test test/models/pet_model_test.dart
```

### Run Tests Matching Pattern

```bash
flutter test --name "PetModel"
```

### Run Tests in Watch Mode

```bash
flutter test --watch
```

---

## Test Structure

```
test/
├── models/                    # Model unit tests
│   ├── pet_model_test.dart
│   ├── user_model_test.dart
│   └── ...
├── controllers/               # Controller state management tests
│   └── (to be added)
└── integration/               # Integration & E2E tests
    └── app_test.dart
```

---

## Writing Model Tests

Models should have complete JSON roundtrip tests:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_dating_app/models/pet_model.dart';

void main() {
  group('PetModel', () {
    test('parses from JSON correctly', () {
      final json = {
        'id': 'pet-123',
        'name': 'Fluffy',
        // ... all fields
      };
      
      final pet = PetModel.fromJson(json);
      expect(pet.id, 'pet-123');
      expect(pet.name, 'Fluffy');
    });

    test('converts to JSON correctly', () {
      final pet = PetModel(
        id: 'pet-123',
        name: 'Fluffy',
        // ... required fields
      );
      
      final json = pet.toJson();
      expect(json['id'], 'pet-123');
    });

    test('roundtrip serialization', () {
      final original = PetModel(...);
      final json = original.toJson();
      final deserialized = PetModel.fromJson(json);
      
      expect(deserialized.id, original.id);
      expect(deserialized.name, original.name);
    });

    test('copyWith creates new instance', () {
      final pet = PetModel(...);
      final updated = pet.copyWith(name: 'NewName');
      
      expect(updated.name, 'NewName');
      expect(pet.name, 'Fluffy'); // Original unchanged
    });
  });
}
```

**Key points:**
- Test all JSON field mappings (snake_case ↔ camelCase)
- Test optional/nullable fields
- Test immutability (copyWith creates new instance)
- Test serialization roundtrip

---

## Writing Controller Tests

Controllers manage state transitions. Test them with mocked repositories:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_dating_app/controllers/pet_controller.dart';
import 'package:pet_dating_app/models/pet_model.dart';

// Mock repository
class MockPetRepository extends Mock implements PetRepository {}

void main() {
  group('PetNotifier', () {
    test('initial state is empty', () {
      final container = ProviderContainer();
      final notifier = PetNotifier();
      
      final state = notifier.build();
      expect(state.myPets, isEmpty);
      expect(state.isLoading, false);
    });

    test('loadPets updates state with fetched pets', () async {
      final mockRepo = MockPetRepository();
      final testPets = [
        PetModel(...),
        PetModel(...),
      ];
      
      when(() => mockRepo.fetchMyPets('user-123'))
        .thenAnswer((_) async => testPets);
      
      final container = ProviderContainer(
        overrides: [
          petRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      
      final notifier = container.read(petProvider.notifier);
      await notifier.loadPets('user-123');
      
      final state = container.read(petProvider);
      expect(state.myPets.length, 2);
      expect(state.isLoading, false);
    });

    test('loadPets handles errors gracefully', () async {
      final mockRepo = MockPetRepository();
      when(() => mockRepo.fetchMyPets('user-123'))
        .thenThrow(Exception('Network error'));
      
      final container = ProviderContainer(
        overrides: [
          petRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      
      final notifier = container.read(petProvider.notifier);
      await notifier.loadPets('user-123');
      
      final state = container.read(petProvider);
      expect(state.error, contains('Network error'));
      expect(state.isLoading, false);
    });
  });
}
```

**Key points:**
- Use `ProviderContainer` for testing Riverpod providers
- Mock repositories with `MockTail`
- Test both success and error paths
- Verify state transitions

---

## Running Tests in CI

Tests run automatically on:
- Push to `main`, `develop`, or feature branches
- Pull requests to `main` or `develop`

View results in GitHub Actions: https://github.com/CodeStorm-Hub/petsphere/actions

**Workflow:** `.github/workflows/test-and-build.yml`

---

## Coverage Goals

| Component | Target | Status |
|-----------|--------|--------|
| Models | 100% | ✅ In progress |
| Controllers | 80% | ⏳ Next phase |
| Repositories | 70% | ⏳ Next phase |
| **Overall** | **70%** | ✅ Started |

---

## Best Practices

### ✅ DO

- Write tests **alongside** code, not after
- Test **behavior**, not implementation
- Use **descriptive test names**: `test('loadPets sets isLoading to true while fetching')` not `test('load')`
- Group related tests with `group()`
- Mock external dependencies (repositories, Supabase, etc.)
- Test **both** success and error paths
- Keep tests **independent** (no test depends on another)
- Use **Arrange-Act-Assert** pattern

### ❌ DON'T

- Test private methods (if you need to, they should be public)
- Mock internal widgets (test the widget behavior, not implementation)
- Use `sleep()` to wait for async operations (use `async`/`await`)
- Hardcode test data (use factories or fixtures)
- Ignore test failures ("flaky tests" point to real bugs)
- Write overly complex tests (if test is complex, production code is too)

---

## Debugging Tests

### Run with verbose output

```bash
flutter test -v
```

### Run single test with debug prints

```bash
flutter test test/models/pet_model_test.dart -v
```

### Run with custom timeout

```bash
flutter test --timeout=120s
```

### Debug in IDE

Set breakpoints in test files and run with debugger:
- VS Code: F5 or Run → Start Debugging
- Android Studio: Run → Debug 'test'

---

## Integration Tests

For full app workflow testing:

```bash
flutter test integration_test/app_test.dart
```

Or on specific device:

```bash
flutter drive --target=integration_test/app_test.dart
```

---

## Performance Testing

Measure test execution time:

```bash
flutter test --reporter json | jq '.tests[] | {name: .name, duration: .duration}'
```

**Target:** Tests should complete in <5 minutes total.

---

## Continuous Improvement

- [ ] Add model tests for each new model
- [ ] Add controller tests for complex state logic
- [ ] Aim for 80%+ coverage on critical paths
- [ ] Use `golden` files for widget visual regression testing (future)
- [ ] Set up performance regression detection (future)

---

## Useful Links

- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Riverpod Testing](https://riverpod.dev/docs/essentials/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Test Coverage Analysis](https://pub.dev/packages/coverage)

---

**Last Updated:** May 5, 2026
**Coverage:** 0% → 10% (models baseline)
