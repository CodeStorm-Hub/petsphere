import 'package:flutter/foundation.dart';

/// Lightweight wrapper around `debugPrint` with a project tag.
///
/// All log lines are stripped from release builds because `debugPrint` itself
/// is a no-op in release mode. Use this everywhere instead of `print` or raw
/// `debugPrint`, so we can later swap in a structured logger (e.g. Sentry,
/// Firebase Crashlytics) in one place.
void appLog(Object? message, {String? tag}) {
  if (!kDebugMode) return;
  final prefix = tag == null ? '[PetSphere]' : '[PetSphere/$tag]';
  debugPrint('$prefix $message');
}

void appLogError(Object error, StackTrace stack, {String? tag}) {
  if (!kDebugMode) return;
  final prefix = tag == null ? '[PetSphere/error]' : '[PetSphere/$tag/error]';
  debugPrint('$prefix $error');
  debugPrintStack(stackTrace: stack);
}
