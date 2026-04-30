import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../models/post_model.dart';
import '../models/pet_model.dart';
import '../models/story_model.dart';
import '../repositories/feed_repository.dart';
import '../repositories/notification_repository.dart';
import 'auth_controller.dart';

// ---------------------------------------------------------------------------
// State wrapper
// ---------------------------------------------------------------------------
class FeedState {
  final List<PostModel> posts;
  final List<StoryModel> stories;
  final bool isLoading;
  final String? error;

  FeedState({
    this.posts = const [],
    this.stories = const [],
    this.isLoading = false,
    this.error,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    List<StoryModel>? stories,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class FeedNotifier extends Notifier<FeedState> {
  RealtimeChannel? _likesChannel;
  RealtimeChannel? _commentsChannel;
  String? _lastFetchedForUserId;

  @override
  FeedState build() {
    // Auto-refetch the feed whenever the auth status flips to authenticated
    // or the active user changes. This guarantees fresh content on cold
    // start (saved session) and on fresh login without forcing the user to
    // pull-to-refresh. Manual refresh via `refresh()` is still available.
    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated &&
          next.user != null &&
          _lastFetchedForUserId != next.user!.id) {
        _lastFetchedForUserId = next.user!.id;
        _fetchPosts();
      } else if (next.status == AuthStatus.unauthenticated) {
        _lastFetchedForUserId = null;
      }
    });

    _setupRealtimeSubscriptions();
    ref.onDispose(_disposeChannels);
    _fetchPosts();
    final authedUser = ref.read(authProvider).user;
    if (authedUser != null) _lastFetchedForUserId = authedUser.id;
    return FeedState(isLoading: true);
  }

  void _setupRealtimeSubscriptions() {
    _likesChannel = feedRepository.subscribeToLikes(
      onLikeChange: _handleRealtimeLike,
    );
    _commentsChannel = feedRepository.subscribeToComments(
      onNewComment: _handleRealtimeComment,
    );
  }

  void _disposeChannels() {
    _likesChannel?.unsubscribe();
    _commentsChannel?.unsubscribe();
  }

  void _handleRealtimeLike(String postId, String petId, bool isInsert) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != postId) return post;
        final likes = List<String>.from(post.likedByPetIds);
        if (isInsert) {
          if (!likes.contains(petId)) likes.add(petId);
        } else {
          likes.remove(petId);
        }
        return post.copyWith(likedByPetIds: likes);
      }).toList(),
    );
  }

  Future<void> _handleRealtimeComment(String postId, String commentId) async {
    final matchingPosts = state.posts.where((p) => p.id == postId);
    if (matchingPosts.isEmpty) return;
    if (matchingPosts.first.comments.any((c) => c.id == commentId)) return;

    try {
      final comment = await feedRepository.fetchComment(commentId);
      state = state.copyWith(
        posts: state.posts.map((post) {
          if (post.id != postId) return post;
          if (post.comments.any((c) => c.id == comment.id)) return post;
          return post.copyWith(comments: [...post.comments, comment]);
        }).toList(),
      );
    } catch (_) {}
  }

  Future<void> _fetchPosts() async {
    try {
      final userId = ref.read(authProvider).user?.id;
      final results = await Future.wait([
        feedRepository.fetchPosts(),
        userId == null
            ? Future.value(<StoryModel>[])
            : feedRepository.fetchStories(userId),
      ]);
      state = state.copyWith(
        posts: results[0] as List<PostModel>,
        stories: results[1] as List<StoryModel>,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _fetchPosts();

  // -------------------------------------------------------------------------
  // Toggle Like (optimistic update then sync with real IDs from server)
  // -------------------------------------------------------------------------
  Future<void> toggleLike(String postId, String currentPetId) async {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != postId) return post;
        final newLikes = List<String>.from(post.likedByPetIds);
        if (newLikes.contains(currentPetId)) {
          newLikes.remove(currentPetId);
        } else {
          newLikes.add(currentPetId);
        }
        return post.copyWith(likedByPetIds: newLikes);
      }).toList(),
    );

    try {
      final updatedLikes =
          await feedRepository.toggleLike(postId, currentPetId);

      // Notify the post owner if it's a new like (not an unlike)
      if (updatedLikes.contains(currentPetId)) {
        try {
          final post = state.posts.firstWhere((p) => p.id == postId);
          final authedUser = ref.read(authProvider).user;
          // Don't notify if liking own post
          if (authedUser != null && post.pet.userId != authedUser.id) {
            notificationRepository.sendNotification(
              targetUserId: post.pet.userId,
              title: 'New Like',
              body: 'Someone liked your post!',
              type: 'post_like',
              entityType: 'post',
              entityId: postId,
              actorPetId: currentPetId,
            );
          }
        } catch (_) {}
      }

      state = state.copyWith(
        posts: state.posts.map((post) {
          if (post.id != postId) return post;
          return post.copyWith(likedByPetIds: updatedLikes);
        }).toList(),
      );
    } catch (_) {
      await _fetchPosts();
    }
  }

  // -------------------------------------------------------------------------
  // Add Post (media URL already uploaded by caller)
  // -------------------------------------------------------------------------
  Future<void> addPost(
    PetModel pet,
    String mediaUrl,
    String caption, {
    String location = '',
    List<String> taggedPetIds = const [],
    List<String> taggedPetNames = const [],
  }) async {
    try {
      final newPost = await feedRepository.createPost(
        petId: pet.id,
        mediaUrl: mediaUrl,
        caption: caption,
        location: location,
        taggedPetIds: taggedPetIds,
        taggedPetNames: taggedPetNames,
      );
      state = state.copyWith(posts: [newPost, ...state.posts]);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create post: $e');
    }
  }

  Future<bool> addStory(PetModel pet, String mediaUrl, String caption) async {
    try {
      final story = await feedRepository.createStory(
        petId: pet.id,
        mediaUrl: mediaUrl,
        caption: caption,
      );
      state = state.copyWith(stories: [story, ...state.stories]);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create story: $e');
      return false;
    }
  }

  Future<bool> deleteStory(String storyId) async {
    try {
      await feedRepository.deleteStory(storyId);
      state = state.copyWith(
        stories: state.stories.where((story) => story.id != storyId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete story: $e');
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Delete Post
  // -------------------------------------------------------------------------
  Future<bool> deletePost(String postId) async {
    try {
      await feedRepository.deletePost(postId);
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete post: $e');
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Add Comment
  // -------------------------------------------------------------------------
  Future<void> addComment(
      String postId, String petId, String petName, String text) async {
    try {
      final newComment = await feedRepository.addComment(
        postId: postId,
        petId: petId,
        text: text,
      );
      state = state.copyWith(
        posts: state.posts.map((post) {
          if (post.id != postId) return post;
          return post.copyWith(comments: [...post.comments, newComment]);
        }).toList(),
      );

      // Notify the post owner
      try {
        final post = state.posts.firstWhere((p) => p.id == postId);
        final authedUser = ref.read(authProvider).user;
        if (authedUser != null && post.pet.userId != authedUser.id) {
          notificationRepository.sendNotification(
            targetUserId: post.pet.userId,
            title: 'New Comment',
            body: '$petName commented: $text',
            type: 'post_comment',
            entityType: 'post',
            entityId: postId,
            actorPetId: petId,
          );
        }
      } catch (_) {}
    } catch (e) {
      state = state.copyWith(error: 'Failed to add comment: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final feedProvider = NotifierProvider<FeedNotifier, FeedState>(() {
  return FeedNotifier();
});

// ---------------------------------------------------------------------------
// Single-post provider used for deep-linking into /post/:id.
//
// Prefers the cached entry in [feedProvider] when available, otherwise
// fetches directly from Supabase. This keeps the detail screen functional
// when opened via a link even if the feed has not been loaded yet.
// ---------------------------------------------------------------------------
final postByIdProvider =
    FutureProvider.family<PostModel?, String>((ref, postId) async {
  final cached = ref.watch(
    feedProvider.select(
      (s) => s.posts.where((p) => p.id == postId).toList(),
    ),
  );
  if (cached.isNotEmpty) return cached.first;
  return feedRepository.fetchPostById(postId);
});
