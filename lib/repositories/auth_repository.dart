import 'dart:developer';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pet_dating_app/models/user_model.dart';
import 'package:pet_dating_app/utils/supabase_config.dart';

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
      data: {'name': name},
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Registration failed. Check your email for a confirmation link.');
    }

    // Profile row is auto-created by the handle_new_user DB trigger.
    // If email confirmation is required, session will be null.
    if (response.session == null) {
      log('Signup pending email confirmation for $email');
    }

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
  // Update the user's profile fields (name, bio, location, profile_image_url)
  // -------------------------------------------------------------------------
  Future<UserModel> updateProfile(String userId, Map<String, dynamic> fields) async {
    final email = supabase.auth.currentUser?.email ?? '';

    final data = await supabase
        .from('profiles')
        .upsert({'id': userId, ...fields})
        .select()
        .single();

    return UserModel.fromJson({...data, 'email': email});
  }

  // -------------------------------------------------------------------------
  // Upload a profile avatar to Supabase Storage — returns the public URL
  // -------------------------------------------------------------------------
  Future<String> uploadAvatar(String userId, File imageFile) async {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final contentType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    // Store in dedicated avatars bucket, one folder per user
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage.from('avatars').upload(
      path,
      imageFile,
      fileOptions: FileOptions(contentType: contentType),
    );

    return supabase.storage.from('avatars').getPublicUrl(path);
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
