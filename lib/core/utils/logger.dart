// Application-wide logging utility.
//
// Prefer this over `debugPrint` for consistent tags + levels.
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _prefix = '[PetSphere]';

  /// Log informational message
  static void info(String message, {String? tag}) {
    final fullMessage = _formatMessage(message, tag);
    if (kDebugMode) {
      debugPrint('$_prefix [INFO] $fullMessage');
    }
    developer.log(fullMessage, name: tag ?? 'app', level: 800);
  }

  /// Log debug message
  static void debug(String message, {String? tag}) {
    final fullMessage = _formatMessage(message, tag);
    if (kDebugMode) {
      debugPrint('$_prefix [DEBUG] $fullMessage');
    }
    developer.log(fullMessage, name: tag ?? 'app', level: 500);
  }

  /// Log warning message
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final fullMessage = _formatMessage(message, tag);
    if (kDebugMode) {
      debugPrint('$_prefix [WARN] $fullMessage');
      if (error != null) debugPrint('  Cause: $error');
      if (stackTrace != null) debugPrint('  Stack: $stackTrace');
    }
    developer.log(
      fullMessage,
      name: tag ?? 'app',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error message with optional stack trace
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final fullMessage = _formatMessage(message, tag);
    if (kDebugMode) {
      debugPrint('$_prefix [ERROR] $fullMessage');
      if (error != null) debugPrint('  Cause: $error');
      if (stackTrace != null) debugPrint('  Stack: $stackTrace');
    }
    developer.log(
      fullMessage,
      name: tag ?? 'app',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _formatMessage(String message, String? tag) {
    return tag != null ? '[$tag] $message' : message;
  }
}
