import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/feed_controller.dart';
import 'components/post_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(feedProvider);
    // Assume current user pet is mockPets[0] for testing interactions
    final currentPetId = mockPets[0].id;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PetSphere',
          style: TextStyle(
            fontFamily: 'InstagramLogoFont', // We don't have this but simulates brand
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              context.push('/messages');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            currentPetId: currentPetId,
            onLikeToggle: () {
              ref.read(feedProvider.notifier).toggleLike(post.id, currentPetId);
            },
            onCommentIconTap: () {
              // Open mock comment bottom sheet
              _showCommentSheet(context, ref, post.id, currentPetId, mockPets[0].name);
            },
          );
        },
      ),
    );
  }

  void _showCommentSheet(BuildContext context, WidgetRef ref, String postId, String currentPetId, String petName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              // ... Usually A ListView of comments goes here
              const SizedBox(height: 100, child: Center(child: Text('Comments loading...'))),
              
              // Comment Input
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onSubmitted: (value) {
                          if(value.trim().isNotEmpty) {
                             ref.read(feedProvider.notifier).addComment(postId, currentPetId, petName, value);
                             Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
