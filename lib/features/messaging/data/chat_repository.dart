import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petfolio/features/messaging/data/models/chat_thread_model.dart';
import 'package:petfolio/features/messaging/data/models/message_model.dart';
import 'package:petfolio/core/constants/supabase_config.dart';

class ChatRepository {
  // -------------------------------------------------------------------------
  // Fetch all threads for a pet (with pet joins & last message)
  // -------------------------------------------------------------------------
  Future<List<ChatThreadModel>> fetchThreads(String myPetId) async {
    final data = await supabase
        .from('chat_threads')
        .select(
          'id, pet_id_1, pet_id_2, created_at, '
          'pet1:pets!pet_id_1(id, name, breed, animal_type, age, bio, profile_image_url, images, is_public_owner, user_id), '
          'pet2:pets!pet_id_2(id, name, breed, animal_type, age, bio, profile_image_url, images, is_public_owner, user_id)',
        )
        .or('pet_id_1.eq.$myPetId,pet_id_2.eq.$myPetId')
        .order('created_at', ascending: false)
        .limit(30);

    final threads = (data as List<dynamic>)
        .map((e) => ChatThreadModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (threads.isEmpty) return threads;

    // Fetch all last messages in parallel instead of sequentially
    final lastMsgs = await Future.wait(
      threads.map((t) => _fetchLastMessage(t.id)),
    );

    return [
      for (var i = 0; i < threads.length; i++)
        threads[i].copyWith(lastMessage: lastMsgs[i]),
    ];
  }

  /// Single thread row for deep links / chat screen when the list cache is stale.
  /// Enforces that [myPetId] participates in the thread (RLS should also enforce).
  Future<ChatThreadModel?> fetchThreadById(
    String threadId,
    String myPetId,
  ) async {
    final data = await supabase
        .from('chat_threads')
        .select(
          'id, pet_id_1, pet_id_2, created_at, '
          'pet1:pets!pet_id_1(id, name, breed, animal_type, age, bio, profile_image_url, images, is_public_owner, user_id), '
          'pet2:pets!pet_id_2(id, name, breed, animal_type, age, bio, profile_image_url, images, is_public_owner, user_id)',
        )
        .eq('id', threadId)
        .or('pet_id_1.eq.$myPetId,pet_id_2.eq.$myPetId')
        .maybeSingle();

    if (data == null) return null;

    final thread = ChatThreadModel.fromJson(data);
    final last = await _fetchLastMessage(threadId);
    return thread.copyWith(lastMessage: last);
  }

  // -------------------------------------------------------------------------
  // Fetch all messages for a thread (oldest first)
  // -------------------------------------------------------------------------
  Future<List<MessageModel>> fetchMessages(String threadId) async {
    final data = await supabase
        .from('messages')
        .select()
        .eq('thread_id', threadId)
        .order('created_at', ascending: true)
        .limit(100);

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
  // Batch-fetch unread message counts for a list of threads
  // Returns a map of threadId -> unread count (messages not sent by myPetId)
  // -------------------------------------------------------------------------
  Future<Map<String, int>> fetchUnreadCountsForThreads(
    List<String> threadIds,
    String myPetId,
  ) async {
    if (threadIds.isEmpty) return {};

    final data = await supabase
        .from('messages')
        .select('thread_id')
        .eq('is_read', false)
        .neq('sender_pet_id', myPetId)
        .inFilter('thread_id', threadIds);

    final counts = <String, int>{};
    for (final row in data as List<dynamic>) {
      final threadId = (row as Map<String, dynamic>)['thread_id'] as String;
      counts[threadId] = (counts[threadId] ?? 0) + 1;
    }
    return counts;
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
  // Subscribe to ALL new message INSERT events for thread-list previews.
  // Payloads must be filtered by Supabase Realtime RLS to rows the user may read.
  // Client-side we ignore threads not in the known set (see [ChatController]).
  // -------------------------------------------------------------------------
  RealtimeChannel subscribeToAllMessages({
    required void Function(MessageModel message) onMessage,
  }) {
    return supabase
        .channel('messages-global')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final msg = MessageModel.fromJson(payload.newRecord);
              onMessage(msg);
            } catch (e, st) {
              developer.log(
                'Realtime message parse failed',
                name: 'ChatRepository',
                error: e,
                stackTrace: st,
              );
            }
          },
        )
        .subscribe();
  }

  // -------------------------------------------------------------------------
  // Create a new chat thread between two pets (idempotent via upsert)
  // -------------------------------------------------------------------------
  Future<String> createOrGetThread(String petId1, String petId2) async {
    // Check both orderings separately — the compound .or() filter is unreliable
    // in supabase_flutter's PostgREST client with nested AND conditions.
    final q1 = await supabase
        .from('chat_threads')
        .select('id')
        .eq('pet_id_1', petId1)
        .eq('pet_id_2', petId2)
        .maybeSingle();
    if (q1 != null) return q1['id'] as String;

    final q2 = await supabase
        .from('chat_threads')
        .select('id')
        .eq('pet_id_1', petId2)
        .eq('pet_id_2', petId1)
        .maybeSingle();
    if (q2 != null) return q2['id'] as String;

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
