import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Supabase project credentials — injected via --dart-define-from-file
// Run with: flutter run --dart-define-from-file=.env.local
// ---------------------------------------------------------------------------
const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);
const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);

/// Throws an informative error if credentials were not injected at build time.
void ensureSupabaseConfigured() {
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Supabase credentials are missing.\n'
      'Run with: flutter run --dart-define-from-file=.env.local',
    );
  }
}

// ---------------------------------------------------------------------------
// Convenience getter — use `supabase.from(...)`, `supabase.auth`, etc.
// ---------------------------------------------------------------------------
SupabaseClient get supabase => Supabase.instance.client;

// ---------------------------------------------------------------------------
// Storage bucket names
// ---------------------------------------------------------------------------
const String kBucketPetImages = 'pet-images';
const String kBucketPostMedia = 'post-media';
const String kBucketProductImages = 'product-images';
