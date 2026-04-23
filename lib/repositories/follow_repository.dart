import '../utils/supabase_config.dart';

class FollowRepository {
  // -------------------------------------------------------------------------
  // Follow an owner (implicitly follows all their pets)
  // -------------------------------------------------------------------------
  Future<void> followOwner(String followerUserId, String followedUserId) async {
    await supabase.from('follows').upsert(
      {
        'follower_user_id': followerUserId,
        'followed_user_id': followedUserId,
      },
      onConflict: 'follower_user_id,followed_user_id',
    );
  }

  // -------------------------------------------------------------------------
  // Unfollow an owner
  // -------------------------------------------------------------------------
  Future<void> unfollowOwner(String followerUserId, String followedUserId) async {
    await supabase
        .from('follows')
        .delete()
        .eq('follower_user_id', followerUserId)
        .not('followed_user_id', 'is', null)
        .eq('followed_user_id', followedUserId);
  }

  // -------------------------------------------------------------------------
  // Follow a specific pet only
  // -------------------------------------------------------------------------
  Future<void> followPet(String followerUserId, String petId) async {
    await supabase.from('follows').upsert(
      {
        'follower_user_id': followerUserId,
        'followed_pet_id': petId,
      },
      onConflict: 'follower_user_id,followed_pet_id',
    );
  }

  // -------------------------------------------------------------------------
  // Unfollow a specific pet
  // -------------------------------------------------------------------------
  Future<void> unfollowPet(String followerUserId, String petId) async {
    await supabase
        .from('follows')
        .delete()
        .eq('follower_user_id', followerUserId)
        .not('followed_pet_id', 'is', null)
        .eq('followed_pet_id', petId);
  }

  // -------------------------------------------------------------------------
  // Check if user follows an owner
  // -------------------------------------------------------------------------
  Future<bool> isFollowingOwner(String followerUserId, String ownerId) async {
    final data = await supabase
        .from('follows')
        .select('id')
        .eq('follower_user_id', followerUserId)
        .not('followed_user_id', 'is', null)
        .eq('followed_user_id', ownerId)
        .maybeSingle();
    return data != null;
  }

  // -------------------------------------------------------------------------
  // Check if user follows a pet (directly OR via owner follow)
  // -------------------------------------------------------------------------
  Future<bool> isFollowingPet(String followerUserId, String petId) async {
    // 1. Direct pet follow
    final directFollow = await supabase
        .from('follows')
        .select('id')
        .eq('follower_user_id', followerUserId)
        .not('followed_pet_id', 'is', null)
        .eq('followed_pet_id', petId)
        .maybeSingle();

    if (directFollow != null) return true;

    // 2. Check if following the pet's owner
    final pet = await supabase
        .from('pets')
        .select('user_id')
        .eq('id', petId)
        .maybeSingle();

    if (pet == null) return false;

    return isFollowingOwner(followerUserId, pet['user_id'] as String);
  }

  // -------------------------------------------------------------------------
  // Get follower count for an owner
  // -------------------------------------------------------------------------
  Future<int> getOwnerFollowerCount(String ownerId) async {
    final data = await supabase
        .from('follows')
        .select('id')
        .not('followed_user_id', 'is', null)
        .eq('followed_user_id', ownerId);
    return (data as List).length;
  }

  // -------------------------------------------------------------------------
  // Get follower count for a pet (direct pet followers + owner followers)
  // Deduplicates users who follow both the owner and the pet individually
  // -------------------------------------------------------------------------
  Future<int> getPetFollowerCount(String petId) async {
    // Get the pet's owner
    final pet = await supabase
        .from('pets')
        .select('user_id')
        .eq('id', petId)
        .maybeSingle();

    if (pet == null) return 0;

    final ownerUserId = pet['user_id'] as String;

    // Direct pet followers
    final directFollowers = await supabase
        .from('follows')
        .select('follower_user_id')
        .not('followed_pet_id', 'is', null)
        .eq('followed_pet_id', petId);

    // Owner followers (they implicitly follow all pets)
    final ownerFollowers = await supabase
        .from('follows')
        .select('follower_user_id')
        .not('followed_user_id', 'is', null)
        .eq('followed_user_id', ownerUserId);

    // Deduplicate
    final uniqueFollowers = <String>{
      ...(directFollowers as List).map((r) => r['follower_user_id'] as String),
      ...(ownerFollowers as List).map((r) => r['follower_user_id'] as String),
    };

    return uniqueFollowers.length;
  }

  // -------------------------------------------------------------------------
  // Get total following count for a user (owners + individual pets)
  // -------------------------------------------------------------------------
  Future<int> getFollowingCount(String userId) async {
    final data = await supabase
        .from('follows')
        .select('id')
        .eq('follower_user_id', userId);
    return (data as List).length;
  }
}

final followRepository = FollowRepository();
