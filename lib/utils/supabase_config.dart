import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Supabase credentials
//
// Prefer build-time defines (Flutter + Supabase guidance):
//   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=your-publishable-key
//
// See: https://supabase.com/docs/guides/getting-started/api-keys
// ---------------------------------------------------------------------------
const String _fromEnvUrl = String.fromEnvironment('SUPABASE_URL');
const String _fromEnvAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// Non-release fallback so local `flutter run` works without defines.
/// Release builds must use `--dart-define` (or CI secrets) — see [assertValidReleaseSupabaseConfig].
const String _debugFallbackUrl = 'https://foubokcqaxyqgjhtgzsx.supabase.co';
const String _debugFallbackAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvdWJva2NxYXh5cWdqaHRnenN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjQ0NjQsImV4cCI6MjA5MDMwMDQ2NH0'
    '.AO7AYHhkoEoNrMUrz-aLOrfWYhTmsmrzkMIwQLBPT2U';

/// URL passed to [Supabase.initialize].
String get supabaseInitUrl {
  if (_fromEnvUrl.isNotEmpty) return _fromEnvUrl;
  if (!kReleaseMode) return _debugFallbackUrl;
  throw StateError(
    'SUPABASE_URL is missing. Pass --dart-define=SUPABASE_URL=https://<project>.supabase.co '
    'for release builds.',
  );
}

/// Publishable (anon) key passed to [Supabase.initialize].
String get supabaseInitAnonKey {
  if (_fromEnvAnonKey.isNotEmpty) return _fromEnvAnonKey;
  if (!kReleaseMode) return _debugFallbackAnonKey;
  throw StateError(
    'SUPABASE_ANON_KEY is missing. Pass --dart-define=SUPABASE_ANON_KEY=<publishable-key> '
    'for release builds.',
  );
}

/// Call from main() after binding init to fail fast in release when misconfigured.
void assertValidReleaseSupabaseConfig() {
  if (!kReleaseMode) return;
  if (_fromEnvUrl.isEmpty || _fromEnvAnonKey.isEmpty) {
    throw StateError(
      'Release builds require SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define '
      '(recommended: GitHub Actions secrets).',
    );
  }
}

// ---------------------------------------------------------------------------
// Convenience getter — use after [Supabase.initialize]
// ---------------------------------------------------------------------------
SupabaseClient get supabase => Supabase.instance.client;

// ---------------------------------------------------------------------------
// Storage bucket names
// ---------------------------------------------------------------------------
const String kBucketPetImages = 'pet-images';
const String kBucketPostMedia = 'post-media';
const String kBucketProductImages = 'product-images';
