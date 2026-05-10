import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/social/data/models/post_model.dart';
import 'package:petfolio/features/social/data/models/story_model.dart';
import 'package:petfolio/core/constants/supabase_config.dart';

class FeedRepository {
  /// Comment rows join commenter pet for name + avatar (post detail UX).
  static const String commentPetEmbed =
      'pets!comments_pet_id_fkey(name, id, profile_image_url)';

  // -------------------------------------------------------------------------
  // Fetch posts with nested pet, likes, and comments data
  // -------------------------------------------------------------------------
  Future<List<PostModel>> fetchPosts() async {
    final data = await supabase
        .from('posts')
        .select(
          '*, pets!posts_pet_id_fkey(*), post_likes(pet_id), comments(*, $commentPetEmbed)',
        )
        .order('created_at', ascending: false)
        .limit(50);

    return data.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<List<StoryModel>> fetchStoriesByPet(String petId) async {
    final data = await supabase
        .from('stories')
        .select('*, pets!stories_pet_id_fkey(*)')
        .eq('pet_id', petId)
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('created_at', ascending: true)
        .limit(50);

    return data.map((e) => StoryModel.fromJson(e)).toList();
  }

  Future<List<PostModel>> fetchPostsByPet(String petId) async {
    final data = await supabase
        .from('posts')
        .select(
          '*, pets!posts_pet_id_fkey(*), post_likes(pet_id), comments(*, $commentPetEmbed)',
        )
        .eq('pet_id', petId)
        .order('created_at', ascending: false)
        .limit(100);

    return data.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<List<PostModel>> fetchPostsByUser(String userId) async {
    final petIdsData = await supabase
        .from('pets')
        .select('id')
        .eq('user_id', userId);
    
    final petIds = petIdsData.map((e) => e['id'] as String).toList();
    if (petIds.isEmpty) return [];

    final data = await supabase
        .from('posts')
        .select(
          '*, pets!posts_pet_id_fkey(*), post_likes(pet_id), comments(*, $commentPetEmbed)',
        )
        .inFilter('pet_id', petIds)
        .order('created_at', ascending: false)
        .limit(100);

    return data.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<List<StoryModel>> fetchStories(String userId) async {
    try {
      final data = await supabase
          .from('stories')
          .select('*, pets!stories_pet_id_fkey(*)')
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false)
          .limit(100);

      final stories = data.map((e) => StoryModel.fromJson(e)).toList();

      if (userId.isEmpty) return stories;

      final myPetsData = await supabase
          .from('pets')
          .select('id')
          .eq('user_id', userId);
      final myPetIds = myPetsData
          .map((row) => row['id'] as String)
          .toSet();

      var followsRows = const <Map<String, dynamic>>[];
      try {
        final followsData = await supabase
            .from('follows')
            .select('followed_user_id, followed_pet_id')
            .eq('follower_user_id', userId);
        followsRows = followsData;
      } catch (e) {
        // If follow graph tables are not migrated yet, keep stories functional
        // by showing only the current user's story pets.
        if (!_isMissingFollowsTable(e)) rethrow;
      }

      final followedUserIds = <String>{};
      final followedPetIds = <String>{};
      for (final row in followsRows) {
        final map = row;
        final followedUserId = map['followed_user_id'] as String?;
        final followedPetId = map['followed_pet_id'] as String?;
        if (followedUserId != null && followedUserId.isNotEmpty) {
          followedUserIds.add(followedUserId);
        }
        if (followedPetId != null && followedPetId.isNotEmpty) {
          followedPetIds.add(followedPetId);
        }
      }

      return stories.where((story) {
        final isMyStory = myPetIds.contains(story.pet.id);
        final isFollowedOwnerStory = followedUserIds.contains(story.pet.userId);
        final isFollowedPetStory = followedPetIds.contains(story.pet.id);
        return isMyStory || isFollowedOwnerStory || isFollowedPetStory;
      }).toList();
    } catch (e) {
      if (_isMissingStoriesTable(e)) return [];
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Fetch a single post by ID — used for deep-linking into /post/:id
  // -------------------------------------------------------------------------
  Future<PostModel?> fetchPostById(String postId) async {
    final data = await supabase
        .from('posts')
        .select(
          '*, pets!posts_pet_id_fkey(*), post_likes(pet_id), comments(*, $commentPetEmbed)',
        )
        .eq('id', postId)
        .maybeSingle();

    if (data == null) return null;
    return PostModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Create a new post (media already uploaded; pass the public URL)
  // -------------------------------------------------------------------------
  Future<PostModel> createPost({
    required String petId,
    required String mediaUrl,
    required String caption,
    String location = '',
    List<String> taggedPetIds = const [],
    List<String> taggedPetNames = const [],
  }) async {
    // Create a temporary PostModel to use its toUpsertJson logic
    // (In a real app, you might just build the map here, but this ensures consistency)
    final post = PostModel(
      id: '', // Will be generated by DB
      pet: PetModel(
        id: petId,
        userId: '',
        name: '',
        breed: '',
        animalType: '',
        age: 0,
        bio: '',
        profileImageUrl: '',
      ), // Only ID matters for insert
      mediaUrl: mediaUrl,
      caption: caption,
      location: location,
      taggedPetIds: taggedPetIds,
      taggedPetNames: taggedPetNames,
      likedByPetIds: [],
      comments: [],
      createdAt: DateTime.now(),
    );

    final payload = post.toUpsertJson();
    debugPrint('Creating post with payload: $payload');

    try {
      final data = await supabase
          .from('posts')
          .insert(payload)
          .select(
            '*, pets!posts_pet_id_fkey(*), post_likes(pet_id), comments(*, $commentPetEmbed)',
          )
          .single();

      debugPrint('Post created successfully: ${data['id']}');
      return PostModel.fromJson(data);
    } catch (e) {
      debugPrint('Error creating post: $e');
      if (!_isMissingPostMetadataColumns(e)) rethrow;
      
      // Fallback for older schemas without extended metadata
      final fallbackPayload = {
        'pet_id': petId,
        'media_url': mediaUrl,
        'caption': caption,
      };
      
      final fallbackData = await supabase
          .from('posts')
          .insert(fallbackPayload)
          .select(
            '*, pets!posts_pet_id_fkey(*), post_likes(pet_id), comments(*, $commentPetEmbed)',
          )
          .single();
      return PostModel.fromJson(fallbackData);
    }
  }

  Future<StoryModel> createStory({
    required String petId,
    required String mediaUrl,
    String caption = '',
  }) async {
    // Explicitly set expires_at to now + 24 h so the expiry window is always
    // enforced even if the DB default were ever changed.
    final expiresAt = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 24))
        .toIso8601String();

    final payload = {
      'pet_id': petId,
      'media_url': mediaUrl,
      'caption': caption,
      'expires_at': expiresAt,
    };
    debugPrint('Creating story with payload: $payload');

    try {
      final data = await supabase
          .from('stories')
          .insert(payload)
          .select('*, pets!stories_pet_id_fkey(*)')
          .single();

      debugPrint('Story created successfully: ${data['id']}');
      return StoryModel.fromJson(data);
    } catch (e) {
      if (_isMissingStoriesTable(e)) {
        throw Exception(
          'Stories are not set up in Supabase yet. Apply supabase/stories_table.sql and reload the schema cache.',
        );
      }
      rethrow;
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await supabase.from('stories').delete().eq('id', storyId);
    } catch (e) {
      if (_isMissingStoriesTable(e)) return;
      rethrow;
    }
  }

  bool _isMissingStoriesTable(Object error) {
    if (error is! PostgrestException) return false;
    final message = error.message.toLowerCase();
    return message.contains('schema cache') &&
        (message.contains('stories') || message.contains('storied'));
  }

  bool _isMissingPostMetadataColumns(Object error) {
    if (error is! PostgrestException) return false;
    final message = error.message.toLowerCase();
    return message.contains('schema cache') &&
        (message.contains('location') ||
            message.contains('tagged_pet_ids') ||
            message.contains('tagged_pet_names'));
  }

  bool _isMissingFollowsTable(Object error) {
    if (error is! PostgrestException) return false;
    final message = error.message.toLowerCase();
    return message.contains('schema cache') && message.contains('follows');
  }

  // -------------------------------------------------------------------------
  // Upload post media to Storage — returns the public URL
  // -------------------------------------------------------------------------
  Future<String> uploadPostMedia(File file) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      throw StateError('Must be signed in to upload post media');
    }
    final ext = file.path.split('.').last;
    final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

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

    return likes.map((l) => l['pet_id'] as String).toList();
  }

  // -------------------------------------------------------------------------
  // Update a post
  // -------------------------------------------------------------------------
  Future<PostModel> updatePost({
    required String postId,
    required String caption,
    String? location,
    List<String>? taggedPetIds,
    List<String>? taggedPetNames,
  }) async {
    final payload = {
      'caption': caption,
      if (location != null && location.isNotEmpty) 'location': location,
      if (taggedPetIds != null && taggedPetIds.isNotEmpty)
        'tagged_pet_ids': taggedPetIds,
      if (taggedPetNames != null && taggedPetNames.isNotEmpty)
        'tagged_pet_names': taggedPetNames,
    };

    final data = await supabase
        .from('posts')
        .update(payload)
        .eq('id', postId)
        .select(
          '*, pets!posts_pet_id_fkey(*), post_likes(pet_id), comments(*, $commentPetEmbed)',
        )
        .single();

    return PostModel.fromJson(data);
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
        .insert({'post_id': postId, 'pet_id': petId, 'text': text})
        .select('*, $commentPetEmbed')
        .single();

    return CommentModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Fetch a single comment with pet join (used by realtime handler)
  // -------------------------------------------------------------------------
  Future<CommentModel> fetchComment(String commentId) async {
    final data = await supabase
        .from('comments')
        .select('*, $commentPetEmbed')
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
    return likes.map((l) => l['pet_id'] as String).toList();
  }

  // -------------------------------------------------------------------------
  // Real-time: subscribe to like changes (insert/delete)
  // -------------------------------------------------------------------------
  RealtimeChannel subscribeToLikes({
    required void Function(String postId, String petId, bool isInsert)
    onLikeChange,
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

FeedRepository feedRepository = FeedRepository();
