import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/core/constants/supabase_config.dart';

void main() {
  test('non-release resolves Supabase URL and anon key', () {
    expect(kReleaseMode, isFalse);
    expect(supabaseInitUrl, isNotEmpty);
    expect(supabaseInitAnonKey, isNotEmpty);
  });

  test('assertValidReleaseSupabaseConfig does not throw in tests (debug)', () {
    expect(() => assertValidReleaseSupabaseConfig(), returnsNormally);
  });
}
