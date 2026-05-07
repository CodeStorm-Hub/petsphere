import 'dart:io';
import 'package:pet_dating_app/models/post_model.dart';
import 'package:pet_dating_app/models/story_model.dart';
import 'package:pet_dating_app/repositories/feed_repository.dart';
import 'package:pet_dating_app/utils/connectivity_service.dart';
import 'package:pet_dating_app/utils/offline_cache.dart';

/// Offline-first wrapper around FeedRepository.
///
/// Strategy:
/// - On reads: Check cache first, fall back to network if cache is stale or empty
/// - On writes: Queue locally if offline, sync when online
/// - Cache TTL: 1 hour for posts, 24 hours for stories
class OfflineFeedRepository {
  final FeedRepository _feedRepository;
  final OfflineCache _cache;
  final ConnectivityService _connectivity;

  static const Duration _postsCacheTTL = Duration(hours: 1);

  OfflineFeedRepository({
    required FeedRepository feedRepository,
    required OfflineCache cache,
    required ConnectivityService connectivity,
  })  : _feedRepository = feedRepository,
        _cache = cache,
        _connectivity = connectivity;

  /// Fetch all posts with offline fallback
  ///
  /// Returns cached posts if offline or cache is fresh.
  /// Fetches from network if online and cache is stale.
  Future<List<PostModel>> fetchPosts() async {
    // If offline and cache exists, return cached data
    if (_connectivity.isOffline) {
      final cached = _cache.getCachedFeedPosts();
      if (cached != null && cached.isNotEmpty) {
        return cached.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      // If offline and no cache, throw error
      throw Exception('No cached posts available and device is offline');
    }

    // If online, check if cache is fresh
    if (_cache.isFeedPostsFresh(_postsCacheTTL)) {
      final cached = _cache.getCachedFeedPosts();
      if (cached != null) {
        return cached.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
      }
    }

    // Cache is stale or missing, fetch from network
    try {
      final posts = await _feedRepository.fetchPosts();
      // Convert models to JSON maps for persistence
      await _cache.cacheFeedPosts(posts.map((p) => p.toJson()).toList());
      return posts;
    } catch (e) {
      // Network error - try returning cached data if available
      final cached = _cache.getCachedFeedPosts();
      if (cached != null && cached.isNotEmpty) {
        return cached.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }

  /// Fetch post by ID
  ///
  /// Always fetches fresh from network (single post lookup).
  /// Falls back to cache if offline.
  Future<PostModel?> fetchPostById(String postId) async {
    if (_connectivity.isOffline) {
      // Try to find in cached posts
      final cached = _cache.getCachedFeedPosts();
      if (cached != null) {
        for (final json in cached) {
          if (json['id'] == postId) {
            return PostModel.fromJson(json as Map<String, dynamic>);
          }
        }
      }
      throw Exception('Post not in cache and device is offline');
    }

    try {
      return await _feedRepository.fetchPostById(postId);
    } catch (e) {
      // Try cache as fallback
      final cached = _cache.getCachedFeedPosts();
      if (cached != null) {
        for (final json in cached) {
          if (json['id'] == postId) {
            return PostModel.fromJson(json as Map<String, dynamic>);
          }
        }
      }
      rethrow;
    }
  }

  /// Create a new post - queued if offline
  ///
  /// Requires mediaUrl to be pre-uploaded. See uploadPostMedia().
  Future<PostModel?> createPost({
    required String petId,
    required String mediaUrl,
    required String caption,
    String location = '',
    List<String> taggedPetIds = const [],
    List<String> taggedPetNames = const [],
  }) async {
    // If offline, queue the operation
    if (_connectivity.isOffline) {
      await _cache.queueSyncOperation(
        operation: 'create',
        table: 'posts',
        data: {
          'pet_id': petId,
          'media_url': mediaUrl,
          'caption': caption,
          'location': location,
          'tagged_pet_ids': taggedPetIds,
          'tagged_pet_names': taggedPetNames,
        },
      );
      return null; // Return null indicating queued
    }

    // Online - create immediately
    final post = await _feedRepository.createPost(
      petId: petId,
      mediaUrl: mediaUrl,
      caption: caption,
      location: location,
      taggedPetIds: taggedPetIds,
      taggedPetNames: taggedPetNames,
    );

    // Invalidate cache since feed has changed
    await _cache.clearCache('offline_feed_posts');

    return post;
  }

  /// Toggle like on a post
  ///
  /// Queued if offline.
  Future<List<String>?> toggleLike(String postId, String petId) async {
    if (_connectivity.isOffline) {
      await _cache.queueSyncOperation(
        operation: 'update',
        table: 'post_likes',
        data: {
          'post_id': postId,
          'pet_id': petId,
          'action': 'toggle',
        },
      );
      return null; // Indicate queued
    }

    return await _feedRepository.toggleLike(postId, petId);
  }

  /// Upload post media to storage
  ///
  /// Must be online. Returns public URL for use in createPost.
  Future<String> uploadPostMedia(File file) async {
    if (_connectivity.isOffline) {
      throw Exception('Cannot upload media while offline');
    }
    return await _feedRepository.uploadPostMedia(file);
  }

  /// Fetch stories (stories are ephemeral, limited offline support)
  ///
  /// Stories expire in 24h so offline caching is limited value.
  /// Best effort: return if online, throw if offline.
  Future<List<StoryModel>> fetchStories(String userId) async {
    if (_connectivity.isOffline) {
      throw Exception('Cannot fetch stories while offline (stories expire in 24h)');
    }

    return await _feedRepository.fetchStories(userId);
  }

  /// Create a story - queued if offline
  ///
  /// Stories are ephemeral (24h expiry), so queuing may not make sense.
  /// Better to require online for story creation.
  Future<StoryModel?> createStory({
    required String petId,
    required String mediaUrl,
    String caption = '',
  }) async {
    if (_connectivity.isOffline) {
      throw Exception('Cannot create story while offline (stories expire in 24h)');
    }

    final story = await _feedRepository.createStory(
      petId: petId,
      mediaUrl: mediaUrl,
      caption: caption,
    );

    // Invalidate stories cache
    await _cache.clearCache('offline_stories');

    return story;
  }

  /// Delete a story
  Future<void> deleteStory(String storyId) async {
    if (_connectivity.isOffline) {
      // Queue for deletion when online
      await _cache.queueSyncOperation(
        operation: 'delete',
        table: 'stories',
        data: {'id': storyId},
      );
      return;
    }

    await _feedRepository.deleteStory(storyId);
    await _cache.clearCache('offline_stories');
  }

  /// Clear feed cache (useful for force refresh)
  Future<void> clearFeedCache() async {
    await _cache.clearCache('offline_feed_posts');
  }

  /// Clear all feed-related caches
  Future<void> clearAllCaches() async {
    await _cache.clearCache('offline_feed_posts');
    await _cache.clearCache('offline_stories');
  }
}
