// Replace with output of `flutterfire configure` for your Firebase project.
// Also add `android/app/google-services.json` from Firebase Console (same package as applicationId).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'CONFIGURE_ME',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'CONFIGURE_ME',
    authDomain: 'CONFIGURE_ME.firebaseapp.com',
    storageBucket: 'CONFIGURE_ME.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWaGVK1Q-QQauS8EoQlAWrKrMdc4rrATQ',
    appId: '1:675318892178:android:93c1b41620e286d3bec84b',
    messagingSenderId: '675318892178',
    projectId: 'petfolio-197e6',
    storageBucket: 'petfolio-197e6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'CONFIGURE_ME',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'CONFIGURE_ME',
    storageBucket: 'CONFIGURE_ME.appspot.com',
    iosBundleId: 'com.example.petDatingApp',
  );
}
