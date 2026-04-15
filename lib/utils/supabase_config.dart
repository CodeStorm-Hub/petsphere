import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Supabase project credentials
// ---------------------------------------------------------------------------
const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://foubokcqaxyqgjhtgzsx.supabase.co',
);
const String supabaseAnonKey =
    String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
          '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvdWJva2NxYXh5cWdqaHRnenN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjQ0NjQsImV4cCI6MjA5MDMwMDQ2NH0'
          '.AO7AYHhkoEoNrMUrz-aLOrfWYhTmsmrzkMIwQLBPT2U',
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
