import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';
import '../models/match_request_model.dart';
import '../utils/supabase_config.dart';

class MatchRepository {
  // -------------------------------------------------------------------------
  // Fetch pets for discovery (excludes ALL owner's pets + already-requested ones)
  // -------------------------------------------------------------------------
  Future<List<PetModel>> fetchDiscoveryPets({
    required String myPetId,
    required String userId,
    String? filterAnimal,
    String? filterBreed,
  }) async {
    debugPrint('[MatchRepository] fetchDiscoveryPets: userId=$userId');

    final requestedRows = await supabase
        .from('match_requests')
        .select('sender_pet_id, receiver_pet_id')
        .or('sender_pet_id.eq.$myPetId,receiver_pet_id.eq.$myPetId');

    final excludedPetIds = <String>{};
    for (final row in requestedRows as List<dynamic>) {
      final request = row as Map<String, dynamic>;
      final senderPetId = request['sender_pet_id'] as String?;
      final receiverPetId = request['receiver_pet_id'] as String?;
      if (senderPetId != null && senderPetId != myPetId) {
        excludedPetIds.add(senderPetId);
      }
      if (receiverPetId != null && receiverPetId != myPetId) {
        excludedPetIds.add(receiverPetId);
      }
    }

    // Simplify to just listed pets NOT owned by me
    var query = supabase
        .from('pets')
        .select()
        .eq('is_breeding_listed', true)
        .neq('user_id', userId);

    if (filterAnimal != null && filterAnimal.isNotEmpty) {
      query = query.eq('animal_type', filterAnimal);
    }
    if (filterBreed != null && filterBreed.isNotEmpty) {
      query = query.eq('breed', filterBreed);
    }

    final data = await query.order('created_at', ascending: false);
    debugPrint('[MatchRepository] Fetched ${(data as List).length} pets from others');

    return (data as List<dynamic>)
        .map((e) => PetModel.fromJson(e as Map<String, dynamic>))
        .where((pet) => !excludedPetIds.contains(pet.id))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Send a like / match request
  // -------------------------------------------------------------------------
  Future<void> sendLikeRequest({
    required String senderPetId,
    required String receiverPetId,
  }) async {
    final existing = await supabase
        .from('match_requests')
        .select('id, sender_pet_id, receiver_pet_id, status')
        .or(
          'and(sender_pet_id.eq.$senderPetId,receiver_pet_id.eq.$receiverPetId),and(sender_pet_id.eq.$receiverPetId,receiver_pet_id.eq.$senderPetId)',
        )
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      final isReciprocalPending =
          existing['sender_pet_id'] == receiverPetId &&
          existing['receiver_pet_id'] == senderPetId &&
          existing['status'] == 'pending';

      if (isReciprocalPending) {
        await supabase
            .from('match_requests')
            .update({'status': 'matched'}).eq('id', existing['id'] as String);
      }
      return;
    }

    await supabase.from('match_requests').insert({
      'sender_pet_id': senderPetId,
      'receiver_pet_id': receiverPetId,
      'status': 'pending',
    });
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
  // Accept or decline a match request
  // -------------------------------------------------------------------------
  Future<void> updateRequestStatus(String requestId, String status) async {
    await supabase
        .from('match_requests')
        .update({'status': status})
        .eq('id', requestId);
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
