import 'package:supabase_flutter/supabase_flutter.dart';

/// Sealed user-facing error type. Repositories map raw `PostgrestException`
/// / `AuthException` / `StorageException` to one of these so the UI can
/// display friendly messages without leaking Supabase internals.
sealed class AppError implements Exception {
  const AppError();

  /// Short message safe to display directly to the user.
  String get userMessage;

  /// Convert any thrown object into an [AppError]. Strings come back unwrapped
  /// so existing code paths continue to work; everything else is mapped by
  /// type. Use this at every repository boundary.
  static AppError from(Object error) {
    if (error is AppError) return error;
    if (error is AuthException) {
      final code = error.statusCode;
      // Supabase returns 400 for "Invalid login credentials" among others.
      if (code == '400' || code == '401' || code == '422') {
        return AuthInvalidCredentials(error.message);
      }
      return AuthFailedError(error.message);
    }
    if (error is PostgrestException) {
      final code = error.code ?? '';
      if (code == 'PGRST116') return const NotFoundError();
      if (code.startsWith('42501') || error.message.contains('row-level security')) {
        return const PermissionError();
      }
      return UnknownError(error.message);
    }
    if (error is StorageException) {
      return UnknownError('Upload failed: ${error.message}');
    }
    return UnknownError(error.toString());
  }
}

class NetworkError extends AppError {
  const NetworkError();
  @override
  String get userMessage =>
      'No internet connection. Check your network and try again.';
}

class AuthInvalidCredentials extends AppError {
  final String raw;
  const AuthInvalidCredentials(this.raw);
  @override
  String get userMessage => 'Email or password is incorrect.';
}

class AuthFailedError extends AppError {
  final String raw;
  const AuthFailedError(this.raw);
  @override
  String get userMessage => raw;
}

class NotFoundError extends AppError {
  const NotFoundError();
  @override
  String get userMessage => 'We couldn\'t find what you were looking for.';
}

class PermissionError extends AppError {
  const PermissionError();
  @override
  String get userMessage => 'You don\'t have permission to do that.';
}

class UnknownError extends AppError {
  final String raw;
  const UnknownError(this.raw);
  @override
  String get userMessage => 'Something went wrong. Please try again.';
}
