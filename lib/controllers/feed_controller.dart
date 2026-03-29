import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../models/pet_model.dart';

// Dummy Pet Data
final mockPets = [
  PetModel(
    id: 'pet-1',
    userId: 'user-1',
    name: 'Bella',
    breed: 'Golden Retriever',
    age: 3,
    bio: 'Loves tennis balls and chasing tails!',
    profileImageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?q=80&w=200&auto=format&fit=crop',
  ),
  PetModel(
    id: 'pet-2',
    userId: 'user-2',
    name: 'Max',
    breed: 'Siberian Husky',
    age: 2,
    bio: 'Snow dog at heart. Awooo!',
    profileImageUrl: 'https://images.unsplash.com/photo-1605568420105-0eebd126dd18?q=80&w=200&auto=format&fit=crop',
  ),
  PetModel(
    id: 'pet-3',
    userId: 'user-3',
    name: 'Luna',
    breed: 'Maine Coon',
    age: 4,
    bio: 'Majestic floof. Will ignore you.',
    profileImageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=200&auto=format&fit=crop',
  ),
];

// Dummy Initial Feed Data
final _initialPosts = [
  PostModel(
    id: 'post-1',
    pet: mockPets[0], // Bella
    mediaUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?q=80&w=600&auto=format&fit=crop',
    caption: 'Best day at the park! Found the biggest stick! 🪵🐕',
    likedByPetIds: ['pet-2', 'pet-3'],
    comments: [
      CommentModel(id: 'c-1', petId: 'pet-2', petName: 'Max', text: 'Looks fun!', createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
    ],
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  PostModel(
    id: 'post-2',
    pet: mockPets[2], // Luna
    mediaUrl: 'https://images.unsplash.com/photo-1573865526739-10659fec78a5?q=80&w=600&auto=format&fit=crop',
    caption: 'I fit, I sit. Box is life. 📦😼',
    likedByPetIds: ['pet-1'],
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
    PostModel(
    id: 'post-3',
    pet: mockPets[1], // Max
    mediaUrl: 'https://images.unsplash.com/photo-1625442750628-9366df65a2d0?q=80&w=600&auto=format&fit=crop',
    caption: 'Waiting for dad to drop some bacon. 🥓👀',
    likedByPetIds: [],
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
];

class FeedNotifier extends Notifier<List<PostModel>> {
  @override
  List<PostModel> build() {
    return _initialPosts;
  }

  void toggleLike(String postId, String currentPetId) {
    state = state.map((post) {
      if (post.id == postId) {
        final List<String> newLikes = List.from(post.likedByPetIds);
        if (newLikes.contains(currentPetId)) {
          newLikes.remove(currentPetId);
        } else {
          newLikes.add(currentPetId);
        }
        return post.copyWith(likedByPetIds: newLikes);
      }
      return post;
    }).toList();
  }

  void addComment(String postId, String petId, String petName, String text) {
    state = state.map((post) {
      if (post.id == postId) {
        final newComment = CommentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          petId: petId,
          petName: petName,
          text: text,
          createdAt: DateTime.now(),
        );
        return post.copyWith(comments: [...post.comments, newComment]);
      }
      return post;
    }).toList();
  }
}

final feedProvider = NotifierProvider<FeedNotifier, List<PostModel>>(() {
  return FeedNotifier();
});
