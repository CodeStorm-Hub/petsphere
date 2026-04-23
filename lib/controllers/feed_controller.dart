import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/pet_model.dart';
import '../repositories/feed_repository.dart';

// ---------------------------------------------------------------------------
// State wrapper
// ---------------------------------------------------------------------------
class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;

  FeedState({this.posts = const [], this.isLoading = false, this.error});

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
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

  @override
  FeedState build() {
    _setupRealtimeSubscriptions();
    ref.onDispose(_disposeChannels);
    Future.microtask(_fetchPosts);
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
      final posts = await feedRepository.fetchPosts();
      state = state.copyWith(posts: posts, isLoading: false, clearError: true);
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
      final updatedLikes = await feedRepository.toggleLike(
        postId,
        currentPetId,
      );
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
  Future<void> addPost(PetModel pet, String mediaUrl, String caption) async {
    try {
      final newPost = await feedRepository.createPost(
        petId: pet.id,
        mediaUrl: mediaUrl,
        caption: caption,
      );
      state = state.copyWith(posts: [newPost, ...state.posts]);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create post: $e');
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
    String postId,
    String petId,
    String petName,
    String text,
  ) async {
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
