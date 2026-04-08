import '../models/pet_model.dart';
import '../models/match_request_model.dart';
import '../utils/supabase_config.dart';

class MatchRepository {
  // -------------------------------------------------------------------------
  // Fetch pets for discovery (excludes the current user's pets + already-requested ones)
  // -------------------------------------------------------------------------
  Future<List<PetModel>> fetchDiscoveryPets({
    required String myPetId,
    String? filterAnimal,
    String? filterBreed,
  }) async {
    // Get IDs already sent or received
    final sentRequests = await supabase
        .from('match_requests')
        .select('receiver_pet_id')
        .eq('sender_pet_id', myPetId);

    final receivedRequests = await supabase
        .from('match_requests')
        .select('sender_pet_id')
        .eq('receiver_pet_id', myPetId);

    final excludedIds = <String>{
      myPetId,
      ...(sentRequests as List).map((r) => r['receiver_pet_id'] as String),
      ...(receivedRequests as List).map((r) => r['sender_pet_id'] as String),
    };

    var query = supabase.from('pets').select().not(
          'id',
          'in',
          '(${excludedIds.map((id) => '"$id"').join(',')})',
        );

    if (filterAnimal != null && filterAnimal.isNotEmpty) {
      query = query.eq('animal_type', filterAnimal);
    }
    if (filterBreed != null && filterBreed.isNotEmpty) {
      query = query.eq('breed', filterBreed);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => PetModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Send a like / match request
  // -------------------------------------------------------------------------
  Future<void> sendLikeRequest({
    required String senderPetId,
    required String receiverPetId,
  }) async {
    await supabase.from('match_requests').upsert({
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
