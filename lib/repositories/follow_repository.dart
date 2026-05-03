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
  Future<void> unfollowOwner(
      String followerUserId, String followedUserId) async {
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
    // Run direct-follow check and pet-owner lookup in parallel
    final results = await Future.wait([
      supabase
          .from('follows')
          .select('id')
          .eq('follower_user_id', followerUserId)
          .not('followed_pet_id', 'is', null)
          .eq('followed_pet_id', petId)
          .maybeSingle(),
      supabase
          .from('pets')
          .select('user_id')
          .eq('id', petId)
          .maybeSingle(),
    ]);

    if (results[0] != null) return true;

    final petData = results[1];
    if (petData == null) return false;

    return isFollowingOwner(followerUserId, petData['user_id'] as String);
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

  // -------------------------------------------------------------------------
  // Get list of follower user IDs (direct pet followers + owner followers)
  // Returns unique follower user IDs with basic user profile info via the
  // users table join.
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchPetFollowersList(String petId) async {
    final pet = await supabase
        .from('pets')
        .select('user_id')
        .eq('id', petId)
        .maybeSingle();

    if (pet == null) return [];
    final ownerUserId = pet['user_id'] as String;

    final results = await Future.wait([
      // Direct pet followers
      supabase
          .from('follows')
          .select('follower_user_id, created_at')
          .not('followed_pet_id', 'is', null)
          .eq('followed_pet_id', petId),
      // Owner followers (implicit pet followers)
      supabase
          .from('follows')
          .select('follower_user_id, created_at')
          .not('followed_user_id', 'is', null)
          .eq('followed_user_id', ownerUserId),
    ]);

    final seen = <String>{};
    final combined = <Map<String, dynamic>>[];

    for (final row in [...(results[0] as List), ...(results[1] as List)]) {
      final userId = row['follower_user_id'] as String;
      if (seen.add(userId)) {
        combined.add({'user_id': userId, 'created_at': row['created_at']});
      }
    }

    if (combined.isEmpty) return [];

    // Fetch user profiles for all follower IDs
    final followerIds = combined.map((r) => r['user_id'] as String).toList();
    final profiles = await supabase
        .from('users')
        .select('id, name, profile_image_url')
        .inFilter('id', followerIds);

    final profileMap = {
      for (final p in profiles as List<dynamic>)
        (p as Map<String, dynamic>)['id'] as String: p,
    };

    return combined.map((r) {
      final uid = r['user_id'] as String;
      final profile = profileMap[uid] ?? {'id': uid, 'name': 'Unknown', 'profile_image_url': ''};
      return {
        'user_id': uid,
        'name': (profile['name'] ?? 'Unknown') as String,
        'profile_image_url': (profile['profile_image_url'] ?? '') as String,
        'created_at': r['created_at'],
      };
    }).toList();
  }
}

final followRepository = FollowRepository();
