import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petfolio/main.dart' as app;

/// Device journey tests against the real app + Supabase.
///
/// Pass `--dart-define=INTEGRATION_TEST=true` so `main()` skips Marionette /
/// Widgets binding init (this file already installs [IntegrationTestWidgetsFlutterBinding]).
///
/// Optional full sign-in:
/// flutter test integration_test/petsphere_journey_test.dart -d emulator-5554 --dart-define=INTEGRATION_TEST=true \
///   --dart-define=E2E_EMAIL=you@example.com \
///   --dart-define=E2E_PASSWORD=yourpassword
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start: login or home; walk bottom nav when logged in', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 25));

    final onLogin = find.text('Welcome Back').evaluate().isNotEmpty;
    final onHome =
        find.text('Atelier').evaluate().isNotEmpty ||
        find.text('PetFolio').evaluate().isNotEmpty;

    expect(
      onLogin || onHome,
      isTrue,
      reason: 'Expected login or main shell after splash',
    );

    if (onLogin) {
      const email = String.fromEnvironment('E2E_EMAIL');
      const password = String.fromEnvironment('E2E_PASSWORD');
      if (email.isNotEmpty && password.isNotEmpty) {
        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          email,
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          password,
        );
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle(const Duration(seconds: 35));
      } else {
        await tester.tap(find.text('Register'));
        await tester.pumpAndSettle(const Duration(seconds: 8));
        expect(find.text('Create Account'), findsOneWidget);
        return;
      }
    }

    if (find.text('Atelier').evaluate().isEmpty &&
        find.text('PetFolio').evaluate().isEmpty) {
      return;
    }

    await exerciseMainShell(tester);
  });
}

Future<void> exerciseMainShell(WidgetTester tester) async {
  Future<void> tapNav(String label) async {
    final target = find.bySemanticsLabel(label);
    expect(target, findsWidgets, reason: 'Missing Semantics label: $label');
    await tester.tap(target.first);
    await tester.pumpAndSettle(const Duration(seconds: 12));
  }

  await tapNav('Discover');
  await tapNav('Home');
  await tapNav('Marketplace');
  await tapNav('Profile');

  await tester.tap(find.bySemanticsLabel('Pet care'));
  await tester.pumpAndSettle(const Duration(seconds: 12));
  expect(find.text('Pet Care'), findsOneWidget);

  await tester.pageBack();
  await tester.pumpAndSettle(const Duration(seconds: 8));

  await tapNav('Home');
}
