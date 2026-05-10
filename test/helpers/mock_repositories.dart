import 'package:mocktail/mocktail.dart';
import 'package:petsphere/features/pet/data/pet_repository.dart';
import 'package:petsphere/features/auth/data/auth_repository.dart';
import 'package:petsphere/features/health/data/health_repository.dart';
import 'package:petsphere/features/care/data/pet_care_repository.dart';
import 'package:petsphere/features/social/data/feed_repository.dart';
import 'package:petsphere/features/messaging/data/chat_repository.dart';
import 'package:petsphere/features/match/data/match_repository.dart';
import 'package:petsphere/features/notifications/data/notification_repository.dart';

// ── Repository Mocks ─────────────────────────────────────────────────────────

class MockPetRepository extends Mock implements PetRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockHealthRepository extends Mock implements HealthRepository {}

class MockPetCareRepository extends Mock implements PetCareRepository {}

class MockFeedRepository extends Mock implements FeedRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockMatchRepository extends Mock implements MatchRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

// ── Common test data ──────────────────────────────────────────────────────────

/// Returns a fixed UTC [DateTime] for use in test assertions.
DateTime get testDate => DateTime.utc(2026, 1, 15, 10);
