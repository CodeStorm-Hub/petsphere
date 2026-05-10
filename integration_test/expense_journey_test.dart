import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/care/data/models/pet_expense_model.dart';
import 'package:petfolio/features/auth/data/models/user_model.dart';
import 'package:petfolio/features/care/data/pet_expense_repository.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/care/presentation/screens/pet_expense_tracker_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/pet/data/pet_repository.dart';


class MockPetExpenseRepository extends Mock implements PetExpenseRepository {}

class MockPetRepository extends Mock implements PetRepository {}


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pet Expense Journey Test', () {
    late MockPetExpenseRepository mockRepo;
    late MockPetRepository mockPetRepo;


    setUpAll(() {
      registerFallbackValue(
        PetExpense(
          id: '',
          petId: '',
          title: '',
          amount: 0,
          date: DateTime.now(),
          category: ExpenseCategory.other,
        ),
      );
    });

    setUp(() {
      mockRepo = MockPetExpenseRepository();
      mockPetRepo = MockPetRepository();
    });


    testWidgets('Should add an expense and verify it appears in the list', (
      tester,
    ) async {
      // 1. Setup Mock Data
      final dummyUser = UserModel(
        id: 'user-456',
        email: 'test@example.com',
        name: 'Tester',
      );
      const dummyPet = PetModel(
        id: 'pet-123',
        userId: 'user-456',
        name: 'Test Buddy',
        breed: 'Husky',
        animalType: 'Dog',
        age: 3,
        bio: 'Test bio',
        profileImageUrl: 'https://example.com/pet.jpg',
      );

      final newExpense = PetExpense(
        id: 'exp-789',
        petId: 'pet-123',
        title: 'Premium Kibble',
        amount: 45.99,
        date: DateTime.now(),
        category: ExpenseCategory.food,
      );

      // 2. Mock Repository Responses
      when(() => mockRepo.fetchExpenses('pet-123')).thenAnswer((_) async => []);
      when(
        () => mockRepo.createExpense(any()),
      ).thenAnswer((_) async => newExpense);

      when(
        () => mockPetRepo.fetchMyPets('user-456'),
      ).thenAnswer((_) async => [dummyPet]);


      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _MockAuthNotifier(dummyUser)),
            activePetProvider.overrideWithValue(dummyPet),
            petRepositoryProvider.overrideWithValue(mockPetRepo),
            petExpenseRepositoryProvider.overrideWithValue(mockRepo),
          ],

          child: const MaterialApp(home: PetExpenseTrackerScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // 3. Verify empty state
      expect(find.text('No expenses logged yet'), findsOneWidget);

      // 4. Add expense
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));
      await tester.enterText(textFields.at(0), 'Premium Kibble');
      await tester.enterText(textFields.at(1), '45.99');

      // Tap Save
      await tester.tap(find.text('Save Expense'));

      // Mock fetch after add
      when(
        () => mockRepo.fetchExpenses('pet-123'),
      ).thenAnswer((_) async => [newExpense]);

      await tester.pumpAndSettle();

      // 5. Verify expense in list
      expect(find.text('Premium Kibble'), findsOneWidget);
      expect(
        find.text('\$45.99'),
        findsWidgets,
      ); // Might be in list and summary
    });
  });
}

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier(this.mockUser);
  final UserModel? mockUser;

  @override
  AuthState build() {
    return AuthState(
      status: mockUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
      user: mockUser,
    );
  }
}
