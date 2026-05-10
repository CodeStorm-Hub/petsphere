import 'dart:math';


import 'package:petfolio/core/constants/supabase_config.dart';

class FollowRepository {
  // -------------------------------------------------------------------------
  // Follow an owner (implicitly follows all their pets)
  // -------------------------------------------------------------------------
  Future<void> followOwner(String followerUserId, String followedUserId) async {
    await supabase.from('follows').upsert({
      'follower_user_id': followerUserId,
      'followed_user_id': followedUserId,
    }, onConflict: 'follower_user_id,followed_user_id');
  }

  // -------------------------------------------------------------------------
  // Unfollow an owner
  // -------------------------------------------------------------------------
  Future<void> unfollowOwner(
    String followerUserId,
    String followedUserId,
  ) async {
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
    await supabase.from('follows').upsert({
      'follower_user_id': followerUserId,
      'followed_pet_id': petId,
    }, onConflict: 'follower_user_id,followed_pet_id');
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
      supabase.from('pets').select('user_id').eq('id', petId).maybeSingle(),
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
    return supabase
        .from('follows')
        .count()
        .not('followed_user_id', 'is', null)
        .eq('followed_user_id', ownerId);
  }

  // -------------------------------------------------------------------------
  // Get follower count for a pet (direct pet followers + owner followers)
  // Deduplicates users who follow both the owner and the pet individually
  // -------------------------------------------------------------------------
  Future<int> getPetFollowerCount(String petId) async {
    final map = await fetchPetFollowerCounts([petId]);
    return map[petId] ?? 0;
  }

  /// Batch follower counts for many pets in a small number of queries (pet direct
  /// follows + implicit owner follows, deduplicated per pet).
  Future<Map<String, int>> fetchPetFollowerCounts(
    Iterable<String> petIdsRaw,
  ) async {
    final ids = petIdsRaw.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return {};

    final petOwnerByPetId = <String, String>{};
    for (var i = 0; i < ids.length; i += _inFilterChunkSize) {
      final chunk = ids.sublist(i, min(i + _inFilterChunkSize, ids.length));
      final rows = await supabase
          .from('pets')
          .select('id, user_id')
          .inFilter('id', chunk);
      for (final row in rows) {
        final id = row['id'] as String?;
        final uid = row['user_id'];
        if (id != null && uid is String) petOwnerByPetId[id] = uid;
      }
    }

    final directByPet = <String, Set<String>>{};
    for (final id in ids) {
      directByPet[id] = {};
    }

    for (var i = 0; i < ids.length; i += _inFilterChunkSize) {
      final chunk = ids.sublist(i, min(i + _inFilterChunkSize, ids.length));
      final rows = await supabase
          .from('follows')
          .select('followed_pet_id, follower_user_id')
          .not('followed_pet_id', 'is', null)
          .inFilter('followed_pet_id', chunk);
      for (final row in rows) {
        final pid = row['followed_pet_id'] as String?;
        final fid = row['follower_user_id'] as String?;
        if (pid == null || fid == null) continue;
        directByPet.putIfAbsent(pid, () => <String>{});
        directByPet[pid]!.add(fid);
      }
    }

    final ownerIds = petOwnerByPetId.values
        .toSet()
        .where((e) => e.isNotEmpty)
        .toList();
    final ownerFollowersByOwnerId = <String, Set<String>>{
      for (final oid in ownerIds) oid: <String>{},
    };

    for (var i = 0; i < ownerIds.length; i += _inFilterChunkSize) {
      final chunk = ownerIds.sublist(
        i,
        min(i + _inFilterChunkSize, ownerIds.length),
      );
      final rows = await supabase
          .from('follows')
          .select('followed_user_id, follower_user_id')
          .not('followed_user_id', 'is', null)
          .inFilter('followed_user_id', chunk);
      for (final row in rows) {
        final oid = row['followed_user_id'] as String?;
        final fid = row['follower_user_id'] as String?;
        if (oid == null || fid == null) continue;
        ownerFollowersByOwnerId.putIfAbsent(oid, () => <String>{});
        ownerFollowersByOwnerId[oid]!.add(fid);
      }
    }

    final out = <String, int>{};
    for (final petId in ids) {
      final ownerId = petOwnerByPetId[petId];
      final direct = directByPet[petId] ?? const <String>{};
      final ownerSide = ownerId == null
          ? const <String>{}
          : (ownerFollowersByOwnerId[ownerId] ?? const <String>{});
      out[petId] = {...direct, ...ownerSide}.length;
    }
    return out;
  }

  // -------------------------------------------------------------------------
  // Get total following count for a user (owners + individual pets)
  // -------------------------------------------------------------------------
  Future<int> getFollowingCount(String userId) async {
    return supabase
        .from('follows')
        .count()
        .eq('follower_user_id', userId);
  }

  // -------------------------------------------------------------------------
  // Get list of follower user IDs (direct pet followers + owner followers)
  // Returns unique follower user IDs with basic user profile info via the
  // profiles table join.
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
          .eq('followed_pet_id', petId)
          .limit(200),
      // Owner followers (implicit pet followers)
      supabase
          .from('follows')
          .select('follower_user_id, created_at')
          .not('followed_user_id', 'is', null)
          .eq('followed_user_id', ownerUserId)
          .limit(200),
    ]);

    final seen = <String>{};
    final combined = <Map<String, dynamic>>[];

    for (final row in [...(results[0] as List<dynamic>), ...(results[1] as List<dynamic>)]) {
      final userId = (row as Map<String, dynamic>)['follower_user_id'] as String;
      if (seen.add(userId)) {
        combined.add({'user_id': userId, 'created_at': row['created_at']});
      }
    }

    return _fetchProfilesForFollowers(combined);
  }

  // -------------------------------------------------------------------------
  // Get list of follower user IDs for an owner
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchOwnerFollowersList(
    String ownerId,
  ) async {
    final data = await supabase
        .from('follows')
        .select('follower_user_id, created_at')
        .not('followed_user_id', 'is', null)
        .eq('followed_user_id', ownerId)
        .limit(200);

    final combined = data
        .map(
          (r) => {
            'user_id': r['follower_user_id'] as String,
            'created_at': r['created_at'],
          },
        )
        .toList();

    return _fetchProfilesForFollowers(combined);
  }

  // -------------------------------------------------------------------------
  // Get list of entities (pets/owners) a user is following
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchFollowingList(String userId) async {
    final data = await supabase
        .from('follows')
        .select('followed_user_id, followed_pet_id, created_at')
        .eq('follower_user_id', userId)
        .limit(200);

    final list = <Map<String, dynamic>>[];
    for (final row in data) {
      final followedUserId = row['followed_user_id'] as String?;
      final followedPetId = row['followed_pet_id'] as String?;

      if (followedUserId != null) {
        list.add({
          'id': followedUserId,
          'type': 'owner',
          'created_at': row['created_at'],
        });
      } else if (followedPetId != null) {
        list.add({
          'id': followedPetId,
          'type': 'pet',
          'created_at': row['created_at'],
        });
      }
    }

    if (list.isEmpty) return [];

    // Fetch details for each
    final ownerIds = list
        .where((e) => e['type'] == 'owner')
        .map((e) => e['id'] as String)
        .toList();
    final petIds = list
        .where((e) => e['type'] == 'pet')
        .map((e) => e['id'] as String)
        .toList();

    final results = await Future.wait([
      if (ownerIds.isNotEmpty)
        _fetchProfilesByIds(ownerIds)
      else
        Future.value(<Map<String, dynamic>>[]),
      if (petIds.isNotEmpty)
        _fetchPetsByIdsForFollowing(petIds)
      else
        Future.value(<Map<String, dynamic>>[]),
    ]);

    final profileMap = {for (final p in results[0]) p['id'] as String: p};
    final petMap = {for (final p in results[1]) p['id'] as String: p};

    return list.map((e) {
      final id = e['id'] as String;
      if (e['type'] == 'owner') {
        final p =
            profileMap[id] ??
            {'id': id, 'name': 'Unknown Owner', 'profile_image_url': ''};
        return {
          'id': id,
          'type': 'owner',
          'name': p['name'] ?? 'Unknown',
          'image_url': p['profile_image_url'] ?? '',
          'created_at': e['created_at'],
        };
      } else {
        final p =
            petMap[id] ??
            {'id': id, 'name': 'Unknown Pet', 'profile_image_url': ''};
        return {
          'id': id,
          'type': 'pet',
          'name': p['name'] ?? 'Unknown',
          'image_url':
              (p['profile_image_url'] ?? p['image_url'] ?? '') as String,
          'created_at': e['created_at'],
        };
      }
    }).toList();
  }

  // -------------------------------------------------------------------------
  // Helper to fetch profile info for a list of user IDs
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> _fetchProfilesForFollowers(
    List<Map<String, dynamic>> followersWithDates,
  ) async {
    if (followersWithDates.isEmpty) return [];

    final followerIds = followersWithDates
        .map((r) => r['user_id'] as String)
        .toList();
    final profiles = await _fetchProfilesByIds(followerIds);

    final profileMap = {for (final p in profiles) p['id'] as String: p};

    return followersWithDates.map((r) {
      final uid = r['user_id'] as String;
      final profile =
          profileMap[uid] ??
          {'id': uid, 'name': 'Unknown', 'profile_image_url': ''};
      return {
        'user_id': uid,
        'name': (profile['name'] ?? 'Unknown') as String,
        'profile_image_url': (profile['profile_image_url'] ?? '') as String,
        'created_at': r['created_at'],
      };
    }).toList();
  }

  static const int _inFilterChunkSize = 100;

  Future<List<Map<String, dynamic>>> _fetchProfilesByIds(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return [];
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < ids.length; i += _inFilterChunkSize) {
      final chunk = ids.sublist(i, min(i + _inFilterChunkSize, ids.length));
      final rows = await supabase
          .from('profiles')
          .select('id, name, profile_image_url')
          .inFilter('id', chunk);
      for (final p in rows) {
        out.add(p);
      }
    }
    return out;
  }

  Future<List<Map<String, dynamic>>> _fetchPetsByIdsForFollowing(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return [];
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < ids.length; i += _inFilterChunkSize) {
      final chunk = ids.sublist(i, min(i + _inFilterChunkSize, ids.length));
      final rows = await supabase
          .from('pets')
          .select('id, name, profile_image_url')
          .inFilter('id', chunk);
      for (final p in rows) {
        out.add(p);
      }
    }
    return out;
  }
}

final followRepository = FollowRepository();
