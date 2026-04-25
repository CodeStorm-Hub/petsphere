import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

final feedRepository = FeedRepository();

final feedRepositoryProvider = Provider((ref) => feedRepository);
