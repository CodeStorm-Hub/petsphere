import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Creates an isolated [SupabaseClient] backed by [MockSupabaseHttpClient].
///
/// Use this in repository unit tests that need to verify Supabase query
/// structure without hitting a real database.
///
/// Example:
/// ```dart
/// final client = createMockSupabaseClient();
/// // client.from('pets').select() returns [] by default
/// ```
SupabaseClient createMockSupabaseClient() {
  final httpClient = MockSupabaseHttpClient();
  return SupabaseClient(
    'https://test.supabase.co',
    'test-anon-key',
    httpClient: httpClient,
  );
}
