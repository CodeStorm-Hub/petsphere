import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_dating_app/models/pet_model.dart';
import 'package:pet_dating_app/models/pet_expense_model.dart';
import 'package:pet_dating_app/models/user_model.dart';
import 'package:pet_dating_app/repositories/pet_expense_repository.dart';
import 'package:pet_dating_app/controllers/pet_controller.dart';
import 'package:pet_dating_app/controllers/auth_controller.dart';
import 'package:pet_dating_app/views/pet_expense_tracker_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockPetExpenseRepository extends Mock implements PetExpenseRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pet Expense Journey Test', () {
    late MockPetExpenseRepository mockRepo;

    setUpAll(() {
      registerFallbackValue(PetExpense(
        id: '',
        petId: '',
        title: '',
        amount: 0,
        date: DateTime.now(),
        category: ExpenseCategory.other,
      ));
    });

    setUp(() {
      mockRepo = MockPetExpenseRepository();
    });

    testWidgets('Should add an expense and verify it appears in the list', (tester) async {
      // 1. Setup Mock Data
      final dummyUser = UserModel(id: 'user-456', email: 'test@example.com', name: 'Tester');
      final dummyPet = PetModel(
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
      when(() => mockRepo.createExpense(any())).thenAnswer((_) async => newExpense);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _MockAuthNotifier(dummyUser)),
            activePetProvider.overrideWithValue(dummyPet),
            petExpenseRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: PetExpenseTrackerScreen(),
          ),
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
      when(() => mockRepo.fetchExpenses('pet-123')).thenAnswer((_) async => [newExpense]);
      
      await tester.pumpAndSettle();

      // 5. Verify expense in list
      expect(find.text('Premium Kibble'), findsOneWidget);
      expect(find.text('\$45.99'), findsWidgets); // Might be in list and summary
    });
  });
}

class _MockAuthNotifier extends AuthNotifier {
  final UserModel? mockUser;
  _MockAuthNotifier(this.mockUser);

  @override
  AuthState build() {
    return AuthState(
      status: mockUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: mockUser,
    );
  }
}
