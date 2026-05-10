import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('PetFolio Journey Tests', () {
    late FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      await driver.close();
    });

    test('Verification: App starts and reaches splash/login', () async {
      // Wait for the app to load
      final health = await driver.checkHealth();
      expect(health.status, HealthStatus.ok);
    });

    // Example of a login journey test (to be expanded by user)
    // test('Login Journey', () async {
    //   final emailField = find.byValueKey('email_field');
    //   final passwordField = find.byValueKey('password_field');
    //   final loginButton = find.byValueKey('login_button');
    //
    //   await driver.tap(emailField);
    //   await driver.enterText('afsanchowdhury25@gmail.com');
    //
    //   await driver.tap(passwordField);
    //   await driver.enterText('callofduty100');
    //
    //   await driver.tap(loginButton);
    //
    //   // Verify landing on home
    //   await driver.waitFor(find.byValueKey('home_dashboard'));
    // });
  });
}
