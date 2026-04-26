import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/follow_repository.dart';
import '../repositories/notification_repository.dart';
import '../utils/supabase_config.dart';
import 'auth_controller.dart';

// ---------------------------------------------------------------------------
// Reactive query providers (auto-refresh on invalidation)
// ---------------------------------------------------------------------------

/// Whether the current user follows a specific owner
final isFollowingOwnerProvider =
    FutureProvider.family<bool, String>((ref, ownerId) async {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null || userId == ownerId) return false;
  return followRepository.isFollowingOwner(userId, ownerId);
});

/// Whether the current user follows a specific pet (directly or via owner)
final isFollowingPetProvider =
    FutureProvider.family<bool, String>((ref, petId) async {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null) return false;
  return followRepository.isFollowingPet(userId, petId);
});

/// Follower count for an owner
final ownerFollowerCountProvider =
    FutureProvider.family<int, String>((ref, ownerId) async {
  return followRepository.getOwnerFollowerCount(ownerId);
});

/// Follower count for a pet (direct + implicit via owner follow, deduplicated)
final petFollowerCountProvider =
    FutureProvider.family<int, String>((ref, petId) async {
  return followRepository.getPetFollowerCount(petId);
});

/// Total following count for a user (owners + individual pets)
final followingCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
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
      final isFollowing =
          await followRepository.isFollowingOwner(userId, ownerId);

      if (isFollowing) {
        await followRepository.unfollowOwner(userId, ownerId);
      } else {
        await followRepository.followOwner(userId, ownerId);
        
        // Notify the owner
        try {
          notificationRepository.sendNotification(
            targetUserId: ownerId,
            title: 'New Follower',
            body: 'Someone started following your profile!',
            type: 'profile_follow',
            entityType: 'profile',
            entityId: userId,
          );
        } catch (_) {}
      }

      // Invalidate related providers so the UI refreshes
      ref.invalidate(isFollowingOwnerProvider(ownerId));
      ref.invalidate(ownerFollowerCountProvider(ownerId));
      ref.invalidate(followingCountProvider(userId));
    } catch (e) {
      debugPrint('toggleFollowOwner error: $e');
    }
  }

  /// Toggle follow on an individual pet. Only follows that specific pet.
  Future<void> toggleFollowPet(String petId) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      final isFollowing =
          await followRepository.isFollowingPet(userId, petId);

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
            notificationRepository.sendNotification(
              targetUserId: targetUserId,
              title: 'New Pet Follower',
              body: 'Someone started following $petName!',
              type: 'pet_follow',
              entityType: 'pet',
              entityId: petId,
            );
          }
        } catch (_) {}
      }

      // Invalidate related providers
      ref.invalidate(isFollowingPetProvider(petId));
      ref.invalidate(petFollowerCountProvider(petId));
      ref.invalidate(followingCountProvider(userId));
    } catch (e) {
      debugPrint('toggleFollowPet error: $e');
    }
  }
}

final followControllerProvider =
    NotifierProvider<FollowController, void>(() => FollowController());
