import 'package:flutter_driver/driver_extension.dart';
import 'package:petsphere/main.dart' as app;

void main() {
  // This line enables the extension.
  enableFlutterDriverExtension();

  // Call the main() function of the app, or call runApp with any widget you
  // want to test.
  app.main();
}
