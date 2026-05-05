import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';
import '../models/match_request_model.dart';
import '../utils/supabase_config.dart';

/// How long a declined breeding profile stays hidden in discovery for the decliner.
const Duration kDiscoveryRejectionCooldown = Duration(days: 7);

class MatchRepository {
  static bool _isRejectionStillInCooldown(Map<String, dynamic> row) {
    if ((row['status'] as String? ?? '') != 'rejected') return false;
    final raw = row['rejected_at'] as String?;
    final rejectedAt =
        raw != null ? DateTime.tryParse(raw)?.toUtc() : null;
    final fallback = row['created_at'] as String?;
    final anchor = rejectedAt ??
        (fallback != null ? DateTime.tryParse(fallback)?.toUtc() : null);
    if (anchor == null) return false;
    return DateTime.now().toUtc().isBefore(anchor.add(kDiscoveryRejectionCooldown));
  }

  // -------------------------------------------------------------------------
  // Fetch pets for discovery (excludes ALL owner's pets + already-requested ones)
  // -------------------------------------------------------------------------
  Future<List<PetModel>> fetchDiscoveryPets({
    required String myPetId,
    required String userId,
    required List<String> allMyPetIds,
    String? filterBreed,
    /// When set, only pets of this [animal_type] are returned (same-kind matching).
    String? viewerAnimalType,
  }) async {
    debugPrint('[MatchRepository] fetchDiscoveryPets: userId=$userId');

    final requestedRows = await supabase
        .from('match_requests')
        .select('sender_pet_id, receiver_pet_id, status, rejected_at, created_at')
        .or('sender_pet_id.eq.$myPetId,receiver_pet_id.eq.$myPetId');

    final excludedPetIds = <String>{};
    for (final row in requestedRows as List<dynamic>) {
      final request = row as Map<String, dynamic>;
      final status = request['status'] as String? ?? 'pending';
      if (status != 'pending' && status != 'matched') {
        continue;
      }
      final senderPetId = request['sender_pet_id'] as String?;
      final receiverPetId = request['receiver_pet_id'] as String?;
      if (senderPetId != null && senderPetId != myPetId) {
        excludedPetIds.add(senderPetId);
      }
      if (receiverPetId != null && receiverPetId != myPetId) {
        excludedPetIds.add(receiverPetId);
      }
    }

    // User-level cooldown: any pet we own declined (receiver) → hide sender in discovery
    // for all our pets for [kDiscoveryRejectionCooldown].
    if (allMyPetIds.isNotEmpty) {
      final cooldownRows = await supabase
          .from('match_requests')
          .select('sender_pet_id, status, rejected_at, created_at')
          .eq('status', 'rejected')
          .inFilter('receiver_pet_id', allMyPetIds);

      for (final row in cooldownRows as List<dynamic>) {
        final map = row as Map<String, dynamic>;
        if (!_isRejectionStillInCooldown(map)) continue;
        final sid = map['sender_pet_id'] as String?;
        if (sid != null) excludedPetIds.add(sid);
      }
    }

    // Simplify to just listed pets NOT owned by me
    var query = supabase
        .from('pets')
        .select()
        .eq('is_breeding_listed', true)
        .neq('user_id', userId);

    final type = viewerAnimalType?.trim();
    if (type != null && type.isNotEmpty) {
      query = query.eq('animal_type', type);
    }
    if (filterBreed != null && filterBreed.isNotEmpty) {
      query = query.eq('breed', filterBreed);
    }

    final data = await query.order('created_at', ascending: false);
    debugPrint(
        '[MatchRepository] Fetched ${(data as List).length} pets from others');

    return (data as List<dynamic>)
        .map((e) => PetModel.fromJson(e as Map<String, dynamic>))
        .where((pet) => !excludedPetIds.contains(pet.id))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Send a like / match request
  // -------------------------------------------------------------------------
  /// Creates or completes a match request.
  ///
  /// Returns the `match_requests.id` row (inserted or updated on mutual match).
  /// Throws [StateError] with message `duplicate_match_request` when a row
  /// already exists but is not the reciprocal-pending case handled here.
  Future<String> sendLikeRequest({
    required String senderPetId,
    required String receiverPetId,
  }) async {
    final existing = await supabase
        .from('match_requests')
        .select(
          'id, sender_pet_id, receiver_pet_id, status, rejected_at, created_at',
        )
        .or(
          'and(sender_pet_id.eq.$senderPetId,receiver_pet_id.eq.$receiverPetId),and(sender_pet_id.eq.$receiverPetId,receiver_pet_id.eq.$senderPetId)',
        )
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      final status = existing['status'] as String? ?? 'pending';
      if (status == 'rejected') {
        if (_isRejectionStillInCooldown(existing)) {
          throw StateError('duplicate_match_request');
        }
        final id = existing['id'] as String;
        await supabase.from('match_requests').update({
          'status': 'pending',
          'rejected_at': null,
        }).eq('id', id);
        return id;
      }

      final isReciprocalPending = existing['sender_pet_id'] == receiverPetId &&
          existing['receiver_pet_id'] == senderPetId &&
          status == 'pending';

      if (isReciprocalPending) {
        final id = existing['id'] as String;
        await supabase
            .from('match_requests')
            .update({'status': 'matched'}).eq('id', id);
        return id;
      }
      throw StateError('duplicate_match_request');
    }

    final inserted = await supabase
        .from('match_requests')
        .insert({
          'sender_pet_id': senderPetId,
          'receiver_pet_id': receiverPetId,
          'status': 'pending',
        })
        .select('id')
        .single();
    return inserted['id'] as String;
  }

  // -------------------------------------------------------------------------
  // Fetch match requests received by myPetId
  // -------------------------------------------------------------------------
  Future<List<MatchRequestModel>> fetchMyRequests(String myPetId) async {
    final data = await supabase
        .from('match_requests')
        .select('*, sender_pets:pets!sender_pet_id(*)')
        .eq('receiver_pet_id', myPetId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => MatchRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Fetch like requests sent by myPetId (with receiver pet details)
  // -------------------------------------------------------------------------
  Future<List<MatchRequestModel>> fetchSentRequests(String myPetId) async {
    final data = await supabase
        .from('match_requests')
        .select('*, receiver_pets:pets!receiver_pet_id(*)')
        .eq('sender_pet_id', myPetId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => MatchRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Fetch ALL match requests received by any of the user's pets
  // Used by the Notifications screen to show requests across all pets.
  // -------------------------------------------------------------------------
  Future<List<MatchRequestModel>> fetchAllMyRequests(List<String> myPetIds) async {
    if (myPetIds.isEmpty) return [];
    final data = await supabase
        .from('match_requests')
        .select('*, sender_pets:pets!sender_pet_id(*)')
        .inFilter('receiver_pet_id', myPetIds)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => MatchRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Accept or decline a match request
  // -------------------------------------------------------------------------
  Future<void> updateRequestStatus(String requestId, String status) async {
    final payload = <String, dynamic>{'status': status};
    if (status == 'rejected') {
      payload['rejected_at'] = DateTime.now().toUtc().toIso8601String();
    }
    if (status == 'matched' || status == 'pending') {
      payload['rejected_at'] = null;
    }
    await supabase.from('match_requests').update(payload).eq('id', requestId);
  }

  // -------------------------------------------------------------------------
  // Check if two pets are already matched
  // -------------------------------------------------------------------------
  Future<bool> areMatched(String petId1, String petId2) async {
    final data = await supabase
        .from('match_requests')
        .select()
        .or('and(sender_pet_id.eq.$petId1,receiver_pet_id.eq.$petId2),and(sender_pet_id.eq.$petId2,receiver_pet_id.eq.$petId1)')
        .eq('status', 'matched')
        .maybeSingle();

    return data != null;
  }
}

final matchRepository = MatchRepository();
