import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../utils/supabase_config.dart';

class AuthRepository {
  // -------------------------------------------------------------------------
  // Sign in with email + password
  // -------------------------------------------------------------------------
  Future<UserModel> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Sign in failed. Please try again.');

    return _fetchProfile(user.id, email);
  }

  // -------------------------------------------------------------------------
  // Register a new user
  // -------------------------------------------------------------------------
  Future<UserModel> signUp(String email, String password, String name) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Registration failed. Check your email for a confirmation link.');
    }

    // Upsert the profile row
    await supabase.from('profiles').upsert({
      'id': user.id,
      'name': name,
    });

    return UserModel(id: user.id, email: email, name: name);
  }

  // -------------------------------------------------------------------------
  // Sign out
  // -------------------------------------------------------------------------
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // -------------------------------------------------------------------------
  // Get the currently authenticated user (null if not logged in)
  // -------------------------------------------------------------------------
  Future<UserModel?> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    try {
      return await _fetchProfile(user.id, user.email ?? '');
    } catch (_) {
      return UserModel(id: user.id, email: user.email ?? '');
    }
  }

  // -------------------------------------------------------------------------
  // Stream of auth state changes
  // -------------------------------------------------------------------------
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------
  Future<UserModel> _fetchProfile(String userId, String email) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      return UserModel(id: userId, email: email);
    }

    return UserModel.fromJson({...data, 'email': email});
  }
}

final authRepository = AuthRepository();
