import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/core/utils/logger.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/notifications/data/notification_repository.dart';
import 'package:petfolio/features/social/data/follow_repository.dart';

// ---------------------------------------------------------------------------
// Reactive query providers (auto-refresh on invalidation)
// ---------------------------------------------------------------------------

/// Whether the current user follows a specific owner
final isFollowingOwnerProvider = FutureProvider.family<bool, String>((
  ref,
  ownerId,
) async {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null || userId == ownerId) return false;
  return followRepository.isFollowingOwner(userId, ownerId);
});

/// Whether the current user follows a specific pet (directly or via owner)
final isFollowingPetProvider = FutureProvider.family<bool, String>((
  ref,
  petId,
) async {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null) return false;
  return followRepository.isFollowingPet(userId, petId);
});

/// Follower count for an owner
final ownerFollowerCountProvider = FutureProvider.family<int, String>((
  ref,
  ownerId,
) async {
  return followRepository.getOwnerFollowerCount(ownerId);
});

/// Follower count for a pet (direct + implicit via owner follow, deduplicated)
final petFollowerCountProvider = FutureProvider.family<int, String>((
  ref,
  petId,
) async {
  return followRepository.getPetFollowerCount(petId);
});

/// Total following count for a user (owners + individual pets)
final followingCountProvider = FutureProvider.family<int, String>((
  ref,
  userId,
) async {
  return followRepository.getFollowingCount(userId);
});

// ---------------------------------------------------------------------------
// Mutation controller
// ---------------------------------------------------------------------------
class FollowController extends Notifier<void> {
  @override
  void build() {}

  /// Toggle follow on an owner. When following an owner, all their pets
  /// are implicitly followed.
  Future<void> toggleFollowOwner(String ownerId) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || userId == ownerId) return;

    try {
      final isFollowing = await followRepository.isFollowingOwner(
        userId,
        ownerId,
      );

      if (isFollowing) {
        await followRepository.unfollowOwner(userId, ownerId);
      } else {
        await followRepository.followOwner(userId, ownerId);

        // Notify the owner
        try {
          unawaited(
            notificationRepository.sendNotification(
              targetUserId: ownerId,
              title: 'New Follower',
              body: 'Someone started following your profile!',
              type: 'profile_follow',
              entityType: 'profile',
              entityId: userId,
            ),
          );
        } catch (_) {}
      }

      _invalidateOwnerFollowProviders(ownerId: ownerId, userId: userId);
    } catch (_) {
      AppLogger.debug('toggleFollowOwner error', tag: 'FollowController');
    }
  }

  /// Toggle follow on an individual pet. Only follows that specific pet.
  Future<void> toggleFollowPet(String petId) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      final isFollowing = await followRepository.isFollowingPet(userId, petId);

      if (isFollowing) {
        // If following via owner, this is a direct pet unfollow only
        await followRepository.unfollowPet(userId, petId);
      } else {
        await followRepository.followPet(userId, petId);

        // Notify the pet's owner
        try {
          final data = await supabase
              .from('pets')
              .select('user_id, name')
              .eq('id', petId)
              .single();
          final targetUserId = data['user_id'] as String;
          final petName = data['name'] as String;

          if (targetUserId != userId) {
            unawaited(
              notificationRepository.sendNotification(
                targetUserId: targetUserId,
                title: 'New Pet Follower',
                body: 'Someone started following $petName!',
                type: 'pet_follow',
                entityType: 'pet',
                entityId: petId,
              ),
            );
          }
        } catch (_) {}
      }

      _invalidatePetFollowProviders(petId: petId, userId: userId);
    } catch (_) {
      AppLogger.debug('toggleFollowPet error', tag: 'FollowController');
    }
  }

  void _invalidateOwnerFollowProviders({
    required String ownerId,
    required String userId,
  }) {
    ref.invalidate(isFollowingOwnerProvider(ownerId));
    ref.invalidate(ownerFollowerCountProvider(ownerId));
    ref.invalidate(ownerFollowersListProvider(ownerId));
    ref.invalidate(followingCountProvider(userId));
    ref.invalidate(followingListProvider(userId));
  }

  void _invalidatePetFollowProviders({
    required String petId,
    required String userId,
  }) {
    ref.invalidate(isFollowingPetProvider(petId));
    ref.invalidate(petFollowerCountProvider(petId));
    ref.invalidate(petFollowersListProvider(petId));
    ref.invalidate(followingCountProvider(userId));
    ref.invalidate(followingListProvider(userId));
  }
}

final followControllerProvider = NotifierProvider<FollowController, void>(
  () => FollowController(),
);

/// Follower list (user profiles) for a specific pet.
final petFollowersListProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      petId,
    ) async {
      return followRepository.fetchPetFollowersList(petId);
    });

/// Follower list (user profiles) for a specific owner.
final ownerFollowersListProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      ownerId,
    ) async {
      return followRepository.fetchOwnerFollowersList(ownerId);
    });

/// List of entities a user is following.
final followingListProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      return followRepository.fetchFollowingList(userId);
    });
