import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_thread_model.dart';
import '../models/message_model.dart';
import '../utils/supabase_config.dart';

class ChatRepository {
  // -------------------------------------------------------------------------
  // Fetch all threads for a pet (with pet joins & last message)
  // -------------------------------------------------------------------------
  Future<List<ChatThreadModel>> fetchThreads(String myPetId) async {
    final data = await supabase
        .from('chat_threads')
        .select('id, pet_id_1, pet_id_2, created_at, '
            'pet1:pets!pet_id_1(id, name, breed, animal_type, age, bio, profile_image_url, images, is_public_owner, user_id), '
            'pet2:pets!pet_id_2(id, name, breed, animal_type, age, bio, profile_image_url, images, is_public_owner, user_id)')
        .or('pet_id_1.eq.$myPetId,pet_id_2.eq.$myPetId')
        .order('created_at', ascending: false);

    final threads = (data as List<dynamic>)
        .map((e) => ChatThreadModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Attach last message to each thread
    final enriched = <ChatThreadModel>[];
    for (final thread in threads) {
      final lastMsg = await _fetchLastMessage(thread.id);
      enriched.add(thread.copyWith(lastMessage: lastMsg));
    }

    return enriched;
  }

  // -------------------------------------------------------------------------
  // Fetch all messages for a thread (oldest first)
  // -------------------------------------------------------------------------
  Future<List<MessageModel>> fetchMessages(String threadId) async {
    final data = await supabase
        .from('messages')
        .select()
        .eq('thread_id', threadId)
        .order('created_at', ascending: true);

    return (data as List<dynamic>)
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Send a message
  // -------------------------------------------------------------------------
  Future<MessageModel> sendMessage({
    required String threadId,
    required String senderPetId,
    required String text,
  }) async {
    final data = await supabase
        .from('messages')
        .insert({
          'thread_id': threadId,
          'sender_pet_id': senderPetId,
          'text': text,
          'is_read': false,
        })
        .select()
        .single();

    return MessageModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Subscribe to new messages in a thread via Supabase Realtime
  // -------------------------------------------------------------------------
  RealtimeChannel subscribeToMessages({
    required String threadId,
    required void Function(MessageModel message) onMessage,
  }) {
    return supabase
        .channel('messages-$threadId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'thread_id',
            value: threadId,
          ),
          callback: (payload) {
            final msg = MessageModel.fromJson(payload.newRecord);
            onMessage(msg);
          },
        )
        .subscribe();
  }

  // -------------------------------------------------------------------------
  // Create a new chat thread between two pets (idempotent via upsert)
  // -------------------------------------------------------------------------
  Future<String> createOrGetThread(String petId1, String petId2) async {
    // Check if thread already exists in either direction
    final existing = await supabase
        .from('chat_threads')
        .select('id')
        .or('and(pet_id_1.eq.$petId1,pet_id_2.eq.$petId2),and(pet_id_1.eq.$petId2,pet_id_2.eq.$petId1)')
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final data = await supabase
        .from('chat_threads')
        .insert({'pet_id_1': petId1, 'pet_id_2': petId2})
        .select('id')
        .single();

    return data['id'] as String;
  }

  // -------------------------------------------------------------------------
  // Mark all messages in a thread as read
  // -------------------------------------------------------------------------
  Future<void> markThreadAsRead(String threadId, String myPetId) async {
    await supabase
        .from('messages')
        .update({'is_read': true})
        .eq('thread_id', threadId)
        .neq('sender_pet_id', myPetId);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------
  Future<MessageModel?> _fetchLastMessage(String threadId) async {
    final data = await supabase
        .from('messages')
        .select()
        .eq('thread_id', threadId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return MessageModel.fromJson(data);
  }
}

final chatRepository = ChatRepository();
