import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care/data/pet_care_repository.dart';
import 'package:petfolio/features/care/data/models/pet_activity_log_model.dart';
import 'package:petfolio/core/constants/supabase_config.dart';
import '../../helpers/mock_supabase.dart';

void main() {
  late PetCareRepository repository;

  setUp(() {
    // Initialize Supabase with a mock client
    final mockClient = createMockSupabaseClient();
    
    // We override the global supabase instance for the test
    // Note: In a real app, you'd inject this via a provider,
    // but here we follow the existing singleton pattern in supabase_config.dart
    debugSupabaseClient = mockClient;
    
    repository = PetCareRepository();
  });

  group('PetCareRepository Pagination Tests', () {
    test('fetchAppointments should be implemented', () async {
      // This is a smoke test to ensure the mocking infrastructure is ready
      // MockSupabaseHttpClient returns [] for any query by default
      final appointments = await repository.fetchAppointments('test-pet-id');
      expect(appointments, isEmpty);
    });

    test('fetchActivityLogs should return a list (paginated)', () async {
      final logs = await repository.fetchActivityLogs('test-pet-id');
      expect(logs, isA<List<PetActivityLog>>());
    });
  });
}
