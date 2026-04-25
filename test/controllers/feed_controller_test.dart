import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_dating_app/controllers/feed_controller.dart';
import 'package:pet_dating_app/repositories/feed_repository.dart';
import 'package:pet_dating_app/models/post_model.dart';
import 'package:pet_dating_app/models/pet_model.dart';
import 'dart:io';

class MockFeedRepository implements FeedRepository {
  int fetchPostsCallCount = 0;
  int toggleLikeCallCount = 0;
  bool shouldFailToggleLike = false;

  @override
  Future<List<PostModel>> fetchPosts() async {
    fetchPostsCallCount++;
    return [
      PostModel(
        id: 'post1',
        pet: PetModel(id: 'pet1', name: 'Pet 1', ownerId: 'owner1', breed: 'Breed 1', type: 'Dog', imageUrl: ''),
        mediaUrl: '',
        caption: 'Caption 1',
        likedByPetIds: [],
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<String>> toggleLike(String postId, String petId) async {
    toggleLikeCallCount++;
    if (shouldFailToggleLike) {
      throw Exception('Failed to toggle like');
    }
    return [petId];
  }

  @override
  Future<PostModel> createPost({required String petId, required String mediaUrl, required String caption}) async {
    throw UnimplementedError();
  }

  @override
  Future<String> uploadPostMedia(File file) async {
    throw UnimplementedError();
  }

  @override
  Future<CommentModel> addComment({required String postId, required String petId, required String text}) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockFeedRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockFeedRepository();
    container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('toggleLike does NOT call fetchPosts on failure and reverts state', () async {
    // Wait for initial fetch
    await container.read(feedProvider.notifier).refresh();
    expect(mockRepository.fetchPostsCallCount, 2); // 1 from build, 1 from refresh

    final initialPost = container.read(feedProvider).posts.first;
    expect(initialPost.likedByPetIds, isEmpty);

    mockRepository.shouldFailToggleLike = true;

    await container.read(feedProvider.notifier).toggleLike('post1', 'pet_me');

    // Optimized behavior: toggleLike should NOT call fetchPosts() on failure
    expect(mockRepository.fetchPostsCallCount, 2);

    // State should be reverted
    final finalPost = container.read(feedProvider).posts.first;
    expect(finalPost.likedByPetIds, isEmpty);
  });
}
