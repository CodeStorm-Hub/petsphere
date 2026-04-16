import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../utils/supabase_config.dart';

class FeedRepository {
  // -------------------------------------------------------------------------
  // Fetch posts with nested pet, likes, and comments data
  // -------------------------------------------------------------------------
  Future<List<PostModel>> fetchPosts() async {
    final data = await supabase
        .from('posts')
        .select('*, pets!posts_pet_id_fkey(*), post_likes(pet_id), comments(*, pets!comments_pet_id_fkey(name, id))')
        .order('created_at', ascending: false)
        .limit(50);

    return (data as List<dynamic>)
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Create a new post (media already uploaded; pass the public URL)
  // -------------------------------------------------------------------------
  Future<PostModel> createPost({
    required String petId,
    required String mediaUrl,
    required String caption,
  }) async {
    final data = await supabase
        .from('posts')
        .insert({
          'pet_id': petId,
          'media_url': mediaUrl,
          'caption': caption,
        })
        .select('*, pets!posts_pet_id_fkey(*), post_likes(pet_id), comments(*, pets!comments_pet_id_fkey(name, id))')
        .single();

    return PostModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Upload post media to Storage — returns the public URL
  // -------------------------------------------------------------------------
  Future<String> uploadPostMedia(File file) async {
    final ext = file.path.split('.').last;
    final path = '${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage.from(kBucketPostMedia).upload(path, file);

    return supabase.storage.from(kBucketPostMedia).getPublicUrl(path);
  }

  // -------------------------------------------------------------------------
  // Toggle like — insert if not liked, delete if already liked
  // Returns the new list of pet IDs that liked the post
  // -------------------------------------------------------------------------
  Future<List<String>> toggleLike(String postId, String petId) async {
    // Check if already liked
    final existing = await supabase
        .from('post_likes')
        .select()
        .eq('post_id', postId)
        .eq('pet_id', petId)
        .maybeSingle();

    if (existing != null) {
      await supabase
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('pet_id', petId);
    } else {
      await supabase.from('post_likes').insert({
        'post_id': postId,
        'pet_id': petId,
      });
    }

    // Return fresh list of liking pet IDs
    final likes = await supabase
        .from('post_likes')
        .select('pet_id')
        .eq('post_id', postId);

    return (likes as List<dynamic>)
        .map((l) => (l as Map<String, dynamic>)['pet_id'] as String)
        .toList();
  }

  // -------------------------------------------------------------------------
  // Delete a post and its related data
  // -------------------------------------------------------------------------
  Future<void> deletePost(String postId) async {
    await supabase.from('posts').delete().eq('id', postId);
  }

  // -------------------------------------------------------------------------
  // Add a comment
  // -------------------------------------------------------------------------
  Future<CommentModel> addComment({
    required String postId,
    required String petId,
    required String text,
  }) async {
    final data = await supabase
        .from('comments')
        .insert({
          'post_id': postId,
          'pet_id': petId,
          'text': text,
        })
        .select('*, pets!comments_pet_id_fkey(name, id)')
        .single();

    return CommentModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Fetch a single comment with pet join (used by realtime handler)
  // -------------------------------------------------------------------------
  Future<CommentModel> fetchComment(String commentId) async {
    final data = await supabase
        .from('comments')
        .select('*, pets!comments_pet_id_fkey(name, id)')
        .eq('id', commentId)
        .single();
    return CommentModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Fetch fresh likes for a specific post
  // -------------------------------------------------------------------------
  Future<List<String>> fetchLikesForPost(String postId) async {
    final likes = await supabase
        .from('post_likes')
        .select('pet_id')
        .eq('post_id', postId);
    return (likes as List<dynamic>)
        .map((l) => (l as Map<String, dynamic>)['pet_id'] as String)
        .toList();
  }

  // -------------------------------------------------------------------------
  // Real-time: subscribe to like changes (insert/delete)
  // -------------------------------------------------------------------------
  RealtimeChannel subscribeToLikes({
    required void Function(String postId, String petId, bool isInsert) onLikeChange,
  }) {
    return supabase
        .channel('feed-likes-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'post_likes',
          callback: (payload) {
            final postId = payload.newRecord['post_id'] as String? ?? '';
            final petId = payload.newRecord['pet_id'] as String? ?? '';
            if (postId.isNotEmpty && petId.isNotEmpty) {
              onLikeChange(postId, petId, true);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'post_likes',
          callback: (payload) {
            final postId = payload.oldRecord['post_id'] as String? ?? '';
            final petId = payload.oldRecord['pet_id'] as String? ?? '';
            if (postId.isNotEmpty && petId.isNotEmpty) {
              onLikeChange(postId, petId, false);
            }
          },
        )
        .subscribe();
  }

  // -------------------------------------------------------------------------
  // Real-time: subscribe to new comments
  // -------------------------------------------------------------------------
  RealtimeChannel subscribeToComments({
    required void Function(String postId, String commentId) onNewComment,
  }) {
    return supabase
        .channel('feed-comments-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'comments',
          callback: (payload) {
            final postId = payload.newRecord['post_id'] as String? ?? '';
            final commentId = payload.newRecord['id'] as String? ?? '';
            if (postId.isNotEmpty && commentId.isNotEmpty) {
              onNewComment(postId, commentId);
            }
          },
        )
        .subscribe();
  }
}

final feedRepository = FeedRepository();
