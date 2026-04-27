import 'dart:io';
import 'package:flutter/foundation.dart';
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

    // Upsert the profile row — non-fatal if it fails (RLS may block)
    try {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'name': name,
      });
    } catch (e) {
      debugPrint('Profile upsert during signup failed (non-fatal): $e');
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
    final path = 'avatars/${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage.from(kBucketAvatars).upload(
      path,
      imageFile,
      fileOptions: FileOptions(contentType: contentType),
    );

    return supabase.storage.from(kBucketAvatars).getPublicUrl(path);
  }

  // -------------------------------------------------------------------------
  // Stream of auth state changes
  // -------------------------------------------------------------------------
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------
  Future<UserModel> fetchPublicProfile(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      return UserModel(id: userId, email: '');
    }

    return UserModel.fromJson({...data, 'email': ''});
  }
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
