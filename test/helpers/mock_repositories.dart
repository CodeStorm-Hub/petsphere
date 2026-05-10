import 'package:mocktail/mocktail.dart';
import 'package:petfolio/features/pet/data/pet_repository.dart';
import 'package:petfolio/features/auth/data/auth_repository.dart';
import 'package:petfolio/features/health/data/health_repository.dart';
import 'package:petfolio/features/care/data/pet_care_repository.dart';
import 'package:petfolio/features/social/data/feed_repository.dart';
import 'package:petfolio/features/messaging/data/chat_repository.dart';
import 'package:petfolio/features/match/data/match_repository.dart';
import 'package:petfolio/features/notifications/data/notification_repository.dart';

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
