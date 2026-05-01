import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_dating_app/main.dart';
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

      // 3. Launch App with Overrides
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _MockAuthNotifier(dummyUser)),
            activePetProvider.overrideWithValue(dummyPet),
            petExpenseRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const PetSphereApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 4. Navigate to Expenses Screen
      // Assuming we can go directly to the route for testing
      // final BuildContext context = tester.element(find.byType(MaterialApp));
      // In a real test, you might tap the UI to navigate, but direct navigation is faster for deep logic tests
      // However, for "integration" we should ideally tap.
      
      // Let's try to find the "Expenses" card or button in Pet Care
      // Or just push the route
      // We'll use the router to go to /expenses
      // (This requires access to the router, which is provided by routerProvider)
      
      // For now, let's assume we are on a screen that has the expense tracker
      // Or we just test the PetExpenseTrackerScreen in isolation but with full provider context
      
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

      // 5. Verify Empty State
      expect(find.text('No expenses recorded yet'), findsOneWidget);

      // 6. Add Expense
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Title (e.g. Pet Food)'), 'Premium Kibble');
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '45.99');
      
      // Tap Save
      await tester.tap(find.text('Save Expense'));
      
      // Mock fetch after add
      when(() => mockRepo.fetchExpenses('pet-123')).thenAnswer((_) async => [newExpense]);
      
      await tester.pumpAndSettle();

      // 7. Verify Expense in List
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
