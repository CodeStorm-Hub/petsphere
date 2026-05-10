import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';

const _pet1 = PetModel(
  id: 'pet-1',
  userId: 'user-1',
  name: 'Buddy',
  animalType: 'dog',
  breed: 'Labrador',
  age: 3,
  bio: 'Friendly dog',
  profileImageUrl: 'https://example.com/buddy.jpg',
);

const _pet2 = PetModel(
  id: 'pet-2',
  userId: 'user-1',
  name: 'Mittens',
  animalType: 'cat',
  breed: 'Persian',
  age: 2,
  bio: 'Indoor cat',
  profileImageUrl: 'https://example.com/mittens.jpg',
);

void main() {
  group('PetState', () {
    test('initial state is empty and not loading', () {
      final state = PetState();

      expect(state.myPets, isEmpty);
      expect(state.activePet, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.hasNoPets, true);
    });

    test('loading state sets isLoading true', () {
      final state = PetState(isLoading: true);

      expect(state.isLoading, true);
      expect(state.hasNoPets, false); // still loading, not "no pets"
    });

    test('hasNoPets is false when pets exist', () {
      final state = PetState(myPets: [_pet1]);

      expect(state.hasNoPets, false);
    });

    test('hasNoPets is false while loading even with empty list', () {
      final state = PetState(isLoading: true);

      expect(state.hasNoPets, false);
    });

    test('copyWith updates myPets', () {
      final initial = PetState();
      final updated = initial.copyWith(myPets: [_pet1, _pet2]);

      expect(updated.myPets.length, 2);
      expect(updated.myPets.first.name, 'Buddy');
      expect(initial.myPets, isEmpty); // immutable
    });

    test('copyWith updates activePet', () {
      final state = PetState(myPets: [_pet1, _pet2]);
      final with1 = state.copyWith(activePet: _pet1);
      final with2 = with1.copyWith(activePet: _pet2);

      expect(with1.activePet?.id, 'pet-1');
      expect(with2.activePet?.id, 'pet-2');
    });

    test('copyWith clears error', () {
      final state = PetState(error: 'Something went wrong');
      final cleared = state.copyWith(clearError: true);

      expect(state.error, 'Something went wrong');
      expect(cleared.error, isNull);
    });

    test('copyWith with error replaces existing error', () {
      final state = PetState(error: 'Old error');
      final updated = state.copyWith(error: 'New error');

      expect(updated.error, 'New error');
    });

    test('copyWith preserves fields not explicitly changed', () {
      final state = PetState(
        myPets: [_pet1],
        activePet: _pet1,
        error: 'err',
      );

      final updated = state.copyWith(isLoading: true);

      expect(updated.myPets.length, 1);
      expect(updated.activePet?.id, 'pet-1');
      expect(updated.isLoading, true);
      expect(updated.error, 'err');
    });

    test('loading transition: sets isLoading then clears on success', () {
      var state = PetState();

      state = state.copyWith(isLoading: true, clearError: true);
      expect(state.isLoading, true);
      expect(state.error, isNull);

      state = state.copyWith(myPets: [_pet1], isLoading: false);
      expect(state.isLoading, false);
      expect(state.myPets.length, 1);
    });

    test('error transition: sets error and stops loading', () {
      var state = PetState(isLoading: true);

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load pets',
      );

      expect(state.isLoading, false);
      expect(state.error, 'Failed to load pets');
      expect(state.myPets, isEmpty);
    });
  });
}
