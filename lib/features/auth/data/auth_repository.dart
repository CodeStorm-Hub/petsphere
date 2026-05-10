import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petfolio/features/auth/data/models/user_model.dart';
import 'package:petfolio/core/constants/supabase_config.dart';

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
      throw Exception(
        'Registration failed. Check your email for a confirmation link.',
      );
    }

    // Create the profile row — fatal if it fails to ensure user has a complete profile
    try {
      await supabase.from('profiles').upsert({'id': user.id, 'name': name});
    } catch (e) {
      // Clean up by signing out the user since profile creation failed.
      // NOTE: Ideally, we would delete the auth user here to allow re-signup with the same email.
      // However, deleting a user requires admin privileges (Service Role key), which should
      // NOT be embedded in the client app.
      // TODO: Implement a Supabase Edge Function 'delete-self' or similar to handle this rollback.
      await supabase.auth.signOut();
      throw Exception(
        'Failed to create your profile. Please try signing up again. If the problem persists, contact support.',
      );
    }

    return UserModel(id: user.id, email: email, name: name);
  }

  // -------------------------------------------------------------------------
  // Sign out
  // -------------------------------------------------------------------------
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Password reset email (deep link / redirect URL must be configured per
  /// [Supabase Flutter setup](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)).
  Future<void> requestPasswordReset(String email) async {
    await supabase.auth.resetPasswordForEmail(email.trim());
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
  Future<UserModel> updateProfile(
    String userId,
    Map<String, dynamic> fields,
  ) async {
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
    final path =
        'avatars/${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage
        .from(kBucketPetImages)
        .upload(
          path,
          imageFile,
          fileOptions: FileOptions(contentType: contentType),
        );

    return supabase.storage.from(kBucketPetImages).getPublicUrl(path);
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
