import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Supabase project credentials
// ---------------------------------------------------------------------------
const String _fallbackSupabaseUrl = 'https://foubokcqaxyqgjhtgzsx.supabase.co';
const String _fallbackSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvdWJva2NxYXh5cWdqaHRnenN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjQ0NjQsImV4cCI6MjA5MDMwMDQ2NH0'
    '.AO7AYHhkoEoNrMUrz-aLOrfWYhTmsmrzkMIwQLBPT2U';

// Prefer compile-time defines:
// flutter run --dart-define-from-file=.env
const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: _fallbackSupabaseUrl,
);
const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: _fallbackSupabaseAnonKey,
);

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
