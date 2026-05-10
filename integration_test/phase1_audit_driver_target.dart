// Entry point for flutter drive --target (instrumented app with driver extension).
// flutter drive --target=integration_test/phase1_audit_driver_target.dart --driver=integration_test/phase1_audit_driver_test.dart -d emulator-5554 --dart-define=FLUTTER_DRIVER_TEST=true
import 'package:flutter_driver/driver_extension.dart';
import 'package:petfolio/main.dart' as app;

void main() {
  enableFlutterDriverExtension();
  app.main();
}
