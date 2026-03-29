import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'dart:async';

// State defining authentication status
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
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Clear error if not provided
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkInitialAuth();
    return AuthState();
  }

  Future<void> _checkInitialAuth() async {
    // Simulate initial load
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      final mockUser = UserModel(id: 'mock-123', email: email, name: 'Pet Lover');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: mockUser,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: "Invalid email or weak password.",
      );
    }
  }

  Future<void> register(String email, String password, String name) async {
     state = state.copyWith(isLoading: true, error: null);
     
     await Future.delayed(const Duration(seconds: 1));
     
     if (email.isNotEmpty && password.length >= 6) {
      final mockUser = UserModel(id: 'mock-123', email: email, name: name);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: mockUser,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: "Registration failed. Please check inputs.",
      );
    }
  }

  void logout() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
