import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/auth/data/models/user_model.dart';

void main() {
  group('AuthState', () {
    test('initial state with default constructor', () {
      final state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('AuthState copyWith creates new instance', () {
      final original = AuthState(
        status: AuthStatus.unauthenticated,
      );

      final updated = original.copyWith(
        status: AuthStatus.authenticated,
        isLoading: true,
      );

      expect(updated.status, AuthStatus.authenticated);
      expect(updated.isLoading, true);
      expect(original.status, AuthStatus.unauthenticated); // Original unchanged
    });

    test('AuthState copyWith can clear error', () {
      final original = AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Previous error',
      );

      final cleared = original.copyWith(clearError: true);

      expect(cleared.error, isNull);
      expect(original.error, 'Previous error'); // Original unchanged
    });

    test('AuthState copyWith preserves existing fields', () {
      final user = UserModel(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User',
      );

      final original = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

      final updated = original.copyWith(isLoading: true);

      expect(updated.status, AuthStatus.authenticated);
      expect(updated.user, user);
      expect(updated.isLoading, true);
    });

    test('AuthStatus enum has expected values', () {
      expect(AuthStatus.initial, isNotNull);
      expect(AuthStatus.authenticated, isNotNull);
      expect(AuthStatus.unauthenticated, isNotNull);
    });

    test('AuthState with minimal parameters', () {
      final state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('AuthState with all parameters', () {
      final user = UserModel(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User',
      );

      final state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

      expect(state.status, AuthStatus.authenticated);
      expect(state.user, user);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith multiple updates at once', () {
      final user1 = UserModel(
        id: 'user-1',
        email: 'user1@example.com',
        name: 'User 1',
      );

      final user2 = UserModel(
        id: 'user-2',
        email: 'user2@example.com',
        name: 'User 2',
      );

      final state1 = AuthState(status: AuthStatus.unauthenticated, user: user1);

      final state2 = state1.copyWith(
        status: AuthStatus.authenticated,
        user: user2,
        isLoading: true,
      );

      expect(state2.status, AuthStatus.authenticated);
      expect(state2.user?.id, 'user-2');
      expect(state2.isLoading, true);
    });
  });
}
