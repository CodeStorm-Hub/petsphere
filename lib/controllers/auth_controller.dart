import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../utils/care_cache.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
enum AuthStatus { initial, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isLoading = false,
    this.error,
  });

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

  @override
  AuthState build() {
    _init();
    return AuthState();
  }

  void _init() {
    // Listen to Supabase auth state changes continuously
    authRepository.authStateChanges.listen((event) async {
      // Skip if we're in the middle of login/register — those set state directly
      if (_isPerformingAuthAction) return;

      final supabaseUser = event.session?.user;
      if (supabaseUser == null) {
        state = AuthState(status: AuthStatus.unauthenticated);
      } else {
        try {
          final user = await authRepository.getCurrentUser();
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
          );
        } catch (e) {
          debugPrint('Auth listener: profile fetch failed: $e');
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
  }

  Future<void> _checkCurrentSession() async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('Session check failed: $e');
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
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Login failed. Please try again.');
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
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      debugPrint('Registration error: $e');
      state =
          state.copyWith(isLoading: false, error: 'Registration failed. $e');
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
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      debugPrint('Profile update error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
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

final publicUserProvider =
    FutureProvider.family<UserModel, String>((ref, userId) {
  return authRepository.fetchPublicProfile(userId);
});
