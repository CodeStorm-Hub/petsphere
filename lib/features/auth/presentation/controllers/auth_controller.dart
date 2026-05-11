import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petfolio/features/auth/data/models/user_model.dart';
import 'package:petfolio/features/auth/data/auth_repository.dart';
import 'package:petfolio/core/constants/app_strings.dart';
import 'package:petfolio/core/constants/app_durations.dart';
import 'package:petfolio/core/utils/logger.dart';
import 'package:petfolio/features/care/data/care_cache.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
enum AuthStatus { initial, unauthenticated, authenticated }

class AuthState {
  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isLoading = false,
    this.error,
  });
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class AuthNotifier extends Notifier<AuthState> {
  // Guard: prevent auth listener from overwriting state during active operations
  bool _isPerformingAuthAction = false;

  /// Supabase auth stream uses the SDK type named `AuthState` (same name as our
  /// widget layer state class); keep this untyped to avoid import clashes.
  StreamSubscription<dynamic>? _authSubscription;

  @override
  AuthState build() {
    ref.onDispose(() => _authSubscription?.cancel());
    _authSubscription ??= authRepository.authStateChanges.listen((event) async {
      // Skip if we're in the middle of login/register — those set state directly
      if (_isPerformingAuthAction) return;

      final supabaseUser = event.session?.user;
      if (supabaseUser == null) {
        state = AuthState(status: AuthStatus.unauthenticated);
      } else {
        try {
          final user = await authRepository.getCurrentUser().timeout(
            AppDurations.authTimeout,
          );
          state = AuthState(status: AuthStatus.authenticated, user: user);
        } on TimeoutException catch (_) {
          AppLogger.warning(AppStrings.authSessionTimeout, tag: 'AuthNotifier');
          state = AuthState(
            status: AuthStatus.authenticated,
            user: UserModel(
              id: supabaseUser.id,
              email: supabaseUser.email ?? '',
            ),
          );
        } catch (e) {
          AppLogger.error(
            AppStrings.authProfileFetchFailed,
            tag: 'AuthNotifier',
            error: e,
          );
          state = AuthState(
            status: AuthStatus.authenticated,
            user: UserModel(
              id: supabaseUser.id,
              email: supabaseUser.email ?? '',
            ),
          );
        }
      }
    });

    // Check current session immediately
    _checkCurrentSession();

    return AuthState();
  }

  Future<void> _checkCurrentSession() async {
    try {
      final user = await authRepository.getCurrentUser().timeout(
        AppDurations.authTimeout,
      );
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } on TimeoutException catch (_) {
      AppLogger.warning(AppStrings.authSessionTimeout, tag: 'AuthNotifier');
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: UserModel(id: supabaseUser.id, email: supabaseUser.email ?? ''),
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      AppLogger.error(
        AppStrings.authSessionCheckFailed,
        tag: 'AuthNotifier',
        error: e,
      );
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  // -------------------------------------------------------------------------
  // Login
  // -------------------------------------------------------------------------
  Future<void> login(String email, String password) async {
    _isPerformingAuthAction = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await authRepository.signIn(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
    } on AuthException catch (e) {
      AppLogger.warning(
        'Login failed for $email',
        tag: 'AuthNotifier',
        error: e,
      );
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      AppLogger.error(
        AppStrings.authLoginFailed,
        tag: 'AuthNotifier',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.authLoginFailed,
      );
    } finally {
      _isPerformingAuthAction = false;
    }
  }

  Future<void> loginWithProvider(OAuthProvider provider) async {
    _isPerformingAuthAction = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await authRepository.signInWithOAuth(provider);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      AppLogger.warning('OAuth login failed', tag: 'AuthNotifier', error: e);
      state = state.copyWith(isLoading: false, error: e.message);
      _isPerformingAuthAction = false;
    } catch (e) {
      AppLogger.error(
        AppStrings.authLoginFailed,
        tag: 'AuthNotifier',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.authLoginFailed,
      );
    } finally {
      _isPerformingAuthAction = false;
    }
  }

  // -------------------------------------------------------------------------
  // Register
  // -------------------------------------------------------------------------
  Future<void> register(String email, String password, String name) async {
    _isPerformingAuthAction = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await authRepository.signUp(email, password, name);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
    } on AuthException catch (e) {
      AppLogger.warning(
        'Registration failed for $email',
        tag: 'AuthNotifier',
        error: e,
      );
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      AppLogger.error(
        AppStrings.authRegistrationFailed,
        tag: 'AuthNotifier',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.authRegistrationFailed,
      );
    } finally {
      _isPerformingAuthAction = false;
    }
  }

  // -------------------------------------------------------------------------
  // Update Profile
  // -------------------------------------------------------------------------
  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    final userId = state.user?.id;
    if (userId == null) return false;

    _isPerformingAuthAction = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedUser = await authRepository.updateProfile(userId, fields);
      state = state.copyWith(user: updatedUser, isLoading: false);
      AppLogger.info('Profile updated successfully', tag: 'AuthNotifier');
      return true;
    } catch (e) {
      AppLogger.error(
        AppStrings.profileUpdateFailed,
        tag: 'AuthNotifier',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.profileUpdateFailed,
      );
      return false;
    } finally {
      _isPerformingAuthAction = false;
    }
  }

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------
  Future<void> logout() async {
    await authRepository.signOut();
    unawaited(CareCache.clearAll());
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

final publicUserProvider = FutureProvider.family<UserModel, String>((
  ref,
  userId,
) {
  return authRepository.fetchPublicProfile(userId);
});
