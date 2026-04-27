import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Supabase project credentials
//
// Preferred: pass at build time with
//   flutter run --dart-define-from-file=.dart_define.json
// (or `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`).
//
// The hardcoded values below are a development fallback only — they will be
// removed once `.dart_define.json` is wired up in CI. **Rotate the anon key
// in the Supabase dashboard before removing the fallback** since it has been
// exposed in git history.
// ---------------------------------------------------------------------------
const String _kFallbackSupabaseUrl = 'https://foubokcqaxyqgjhtgzsx.supabase.co';
const String _kFallbackSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvdWJva2NxYXh5cWdqaHRnenN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjQ0NjQsImV4cCI6MjA5MDMwMDQ2NH0'
    '.AO7AYHhkoEoNrMUrz-aLOrfWYhTmsmrzkMIwQLBPT2U';

const String _kBuildSupabaseUrl =
    String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const String _kBuildSupabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

final String supabaseUrl =
    _kBuildSupabaseUrl.isNotEmpty ? _kBuildSupabaseUrl : _kFallbackSupabaseUrl;
final String supabaseAnonKey = _kBuildSupabaseAnonKey.isNotEmpty
    ? _kBuildSupabaseAnonKey
    : _kFallbackSupabaseAnonKey;

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
const String kBucketAvatars = 'avatars';
