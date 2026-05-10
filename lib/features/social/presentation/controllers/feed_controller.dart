import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petsphere/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petsphere/features/pet/data/models/pet_model.dart';
import 'package:petsphere/features/social/data/feed_repository.dart';
import 'package:petsphere/features/social/data/models/post_model.dart';
import 'package:petsphere/features/social/data/models/story_model.dart';

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

  List<StoryModel> get visibleStories =>
      stories.where((story) => !story.isExpired).toList();
}

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() {
    Future.microtask(refresh);
    return FeedState(isLoading: true);
  }

  Future<void> refresh() async {
    final auth = ref.read(authProvider);
    if (auth.user == null) {
      state = FeedState();
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final posts = await feedRepository.fetchPosts();
      final stories = await feedRepository.fetchStories(auth.user!.id);
      state = state.copyWith(posts: posts, stories: stories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createPost({
    required String petId,
    required String mediaUrl,
    required String caption,
    String location = '',
    List<String> taggedPetIds = const [],
    List<String> taggedPetNames = const [],
  }) async {
    try {
      final post = await feedRepository.createPost(
        petId: petId,
        mediaUrl: mediaUrl,
        caption: caption,
        location: location,
        taggedPetIds: taggedPetIds,
        taggedPetNames: taggedPetNames,
      );
      state = state.copyWith(posts: [post, ...state.posts]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> createStory({
    required String petId,
    required String mediaUrl,
    String caption = '',
  }) async {
    try {
      final story = await feedRepository.createStory(
        petId: petId,
        mediaUrl: mediaUrl,
        caption: caption,
      );
      state = state.copyWith(stories: [story, ...state.stories]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> toggleLike(String postId, String petId) async {
    try {
      final likedByPetIds = await feedRepository.toggleLike(postId, petId);
      final updated = state.posts.map((post) {
        if (post.id != postId) return post;
        return post.copyWith(likedByPetIds: likedByPetIds);
      }).toList();
      state = state.copyWith(posts: updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updatePost({required String postId, required String caption}) async {
    try {
      final updatedPost = await feedRepository.updatePost(
        postId: postId,
        caption: caption,
      );
      final updated = state.posts.map((post) {
        if (post.id != postId) return post;
        return updatedPost;
      }).toList();
      state = state.copyWith(posts: updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await feedRepository.deletePost(postId);
      state = state.copyWith(
        posts: state.posts.where((post) => post.id != postId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> addComment(
    String postId,
    String petId,
    String petName,
    String content,
  ) async {
    try {
      final comment = await feedRepository.addComment(
        postId: postId,
        petId: petId,
        text: content,
      );
      final updated = state.posts.map((post) {
        if (post.id != postId) return post;
        return post.copyWith(comments: [...post.comments, comment]);
      }).toList();
      state = state.copyWith(posts: updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> addPost(
    Object pet,
    String mediaUrl,
    String caption, {
    String location = '',
    List<String> taggedPetIds = const [],
    List<String> taggedPetNames = const [],
  }) {
    final petId = pet is PetModel ? pet.id : pet.toString();
    return createPost(
      petId: petId,
      mediaUrl: mediaUrl,
      caption: caption,
      location: location,
      taggedPetIds: taggedPetIds,
      taggedPetNames: taggedPetNames,
    );
  }

  Future<bool> addStory(Object pet, String mediaUrl, [String caption = '']) {
    final petId = pet is PetModel ? pet.id : pet.toString();
    return createStory(petId: petId, mediaUrl: mediaUrl, caption: caption);
  }
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);
