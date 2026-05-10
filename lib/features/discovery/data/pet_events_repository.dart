import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/pet_event_models.dart';

class PetEventsRepository {

  PetEventsRepository(this._client);
  final SupabaseClient _client;

  Future<List<PetEvent>> getEvents({String? type}) async {
    var query = _client.from('pet_events').select().eq('is_active', true);

    if (type != null && type != 'All') {
      query = query.eq('event_type', type.toLowerCase());
    }

    final response = await query.order('event_date', ascending: true);

    return (response as List)
        .cast<Map<String, dynamic>>()
        .map(PetEvent.fromJson)
        .toList();
  }

  Future<PetEvent> getEventById(String id) async {
    final response = await _client
        .from('pet_events')
        .select()
        .eq('id', id)
        .single();

    return PetEvent.fromJson(response);
  }

  Future<void> rsvpToEvent(String eventId, String userId) async {
    await _client.from('pet_event_rsvps').upsert({
      'event_id': eventId,
      'user_id': userId,
      'rsvp_at': DateTime.now().toIso8601String(),
    });
  }
}
