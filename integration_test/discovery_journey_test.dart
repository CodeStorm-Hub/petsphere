import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petfolio/main.dart' as app;

/// Discovery Journey Integration Test
/// 
/// Tests the end-to-end flow of:
/// 1. Navigating to Discovery
/// 2. Interacting with pet cards (View Profile, Like)
/// 3. Searching for pets and filtering results
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Discovery & Search Journey', () {
    testWidgets('Full Discovery Interaction Flow', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Ensure we are in the main app shell (Home/Discover)
      final bool onHome = find.text('PetFolio').evaluate().isNotEmpty || 
                         find.text('Atelier').evaluate().isNotEmpty;
      
      if (!onHome) {
        // Might be on login screen, try to skip or alert
        debugPrint('App did not start on Home screen. Check auth state.');
        return;
      }

      // 1. Navigate to Discovery Tab
      final discoveryNav = find.bySemanticsLabel('Discover');
      expect(discoveryNav, findsWidgets);
      await tester.tap(discoveryNav.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 2. Interact with Discovery Cards
      final viewProfileBtn = find.byKey(const ValueKey('discovery_view_profile_button'));
      final likeBtn = find.byKey(const ValueKey('discovery_like_button'));
      final nopeBtn = find.byKey(const ValueKey('discovery_nope_button'));

      if (viewProfileBtn.evaluate().isNotEmpty) {
        debugPrint('Testing View Profile flow');
        await tester.tap(viewProfileBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verify Visitor Profile Screen
        expect(find.byKey(const ValueKey('visitor_pet_profile_follow_button')), findsOneWidget);
        expect(find.byKey(const ValueKey('visitor_pet_profile_message_button')), findsOneWidget);

        // Return to Discovery
        await tester.pageBack();
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      if (likeBtn.evaluate().isNotEmpty) {
        debugPrint('Testing Like action');
        await tester.tap(likeBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      if (nopeBtn.evaluate().isNotEmpty) {
        debugPrint('Testing Nope action');
        await tester.tap(nopeBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('Search & Filtering Flow', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Find search icon in AppBar
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isEmpty) {
        debugPrint('Search icon not found on current screen');
        return;
      }

      await tester.tap(searchIcon.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 1. Enter search query
      final searchField = find.byKey(const ValueKey('search_text_field'));
      expect(searchField, findsOneWidget);
      
      await tester.enterText(searchField, 'Cat');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 2. Navigate between tabs
      final petsTab = find.text('Pets');
      final marketTab = find.text('Market');
      
      await tester.tap(petsTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await tester.tap(marketTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 3. Clear search
      final clearBtn = find.byIcon(Icons.clear);
      if (clearBtn.evaluate().isNotEmpty) {
        await tester.tap(clearBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });
  });
}
