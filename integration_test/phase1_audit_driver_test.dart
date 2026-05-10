// Driver test for flutter drive --driver (package:test only, never flutter_test).
//
// User journey: Phase 1 audit - reach main shell (or login), sign in if needed.
// Frame sync off: progress indicators keep transient callbacks active.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

enum _Landing { shell, login }

Future<_Landing> _waitForLanding(FlutterDriver driver) async {
  try {
    await driver.waitFor(
      find.text('Atelier'),
      timeout: const Duration(seconds: 45),
    );
    return _Landing.shell;
  } catch (_) {}

  try {
    await driver.waitFor(
      find.byValueKey('login_email_field'),
      timeout: const Duration(seconds: 75),
    );
    return _Landing.login;
  } catch (_) {}

  await driver.waitFor(
    find.text('Atelier'),
    timeout: const Duration(seconds: 120),
  );
  return _Landing.shell;
}

Future<void> _assertMainShell(FlutterDriver driver) async {
  await driver.waitFor(
    find.text('Atelier'),
    timeout: const Duration(seconds: 60),
  );
  await driver.waitFor(
    find.byTooltip('Search'),
    timeout: const Duration(seconds: 45),
  );
}

void main() {
  group('Phase 1 audit: login / home (driver)', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test(
      'Login if needed, then main shell nav (Home, Discover)',
      () async {
        await driver.runUnsynchronized(() async {
          await driver.checkHealth();

          final landing = await _waitForLanding(driver);
          if (landing == _Landing.login) {
            await driver.tap(find.byValueKey('login_email_field'));
            await driver.enterText('afsanchowdhury25@gmail.com');
            await driver.tap(find.byValueKey('login_password_field'));
            await driver.enterText('callofduty100');
            await driver.tap(find.text('Sign In'));
            await _assertMainShell(driver);
          }

          await driver.waitFor(
            find.byValueKey('bottom_nav_1'),
            timeout: const Duration(seconds: 30),
          );
        }, timeout: const Duration(minutes: 7));
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );
  });
}
