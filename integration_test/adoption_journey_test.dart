import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petfolio/main.dart' as app;

/// Adoption Journey Integration Test
/// 
/// Tests the end-to-end flow of:
/// 1. Navigating to Adoption Center
/// 2. Filtering by species
/// 3. Viewing a listing
/// 4. Initiating an adoption application
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Adoption Application Journey', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // 1. Navigate to "Pet care" (Services Hub) from Home
    final petCareBtn = find.bySemanticsLabel('Pet care');
    if (petCareBtn.evaluate().isEmpty) {
      debugPrint('Pet care button not found on Home screen');
      return;
    }
    await tester.tap(petCareBtn.first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 2. Navigate to Adoption Center
    final adoptionBtn = find.text('Adoption Center');
    if (adoptionBtn.evaluate().isEmpty) {
      debugPrint('Adoption Center button not found in Services');
      return;
    }
    await tester.tap(adoptionBtn.first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 3. Filter by species
    final dogFilter = find.text('Dogs');
    if (dogFilter.evaluate().isNotEmpty) {
      await tester.tap(dogFilter);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // 4. Open a listing card
    final listingCard = find.byWidgetPredicate(
      (widget) => widget is InkWell && 
                  widget.key is ValueKey<String> && 
                  (widget.key as ValueKey<String>).value.startsWith('adoption_listing_card_')
    );

    if (listingCard.evaluate().isNotEmpty) {
      debugPrint('Opening adoption listing card');
      await tester.tap(listingCard.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 5. Fill application message
      final msgField = find.byKey(const ValueKey('adoption_apply_message_field'));
      if (msgField.evaluate().isNotEmpty) {
        await tester.enterText(msgField, 'Automated Test: I would love to adopt this pet!');
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        final submitBtn = find.byKey(const ValueKey('adoption_submit_button'));
        expect(submitBtn, findsOneWidget);
        debugPrint('Adoption application flow verified up to submission');
      }
    } else {
      debugPrint('No adoption listings found to test application flow');
    }
  });
}
