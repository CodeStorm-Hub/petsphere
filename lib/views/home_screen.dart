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
            onPressed: () {
              context.push('/notifications');
            },
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
              _showCommentSheet(context, post.id, currentPetId, mockPets[0].name);
            },
            onShareIconTap: () {
              _showShareSheet(context);
            },
          );
        },
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // Search Bar Mock
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mock Friends Horizontal Auto-Send Carousel
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: mockPets.length,
                  itemBuilder: (context, index) {
                    final friend = mockPets[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sent post to ${friend.name}!')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(friend.profileImageUrl),
                            ),
                            const SizedBox(height: 8),
                            Text(friend.name, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade100),
                  child: const Icon(Icons.add_to_photos_rounded),
                ),
                title: const Text('Add to your story'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade100),
                  child: const Icon(Icons.link),
                ),
                title: const Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard!')));
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade100),
                  child: const Icon(Icons.share),
                ),
                title: const Text('Share via...'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentSheet(BuildContext context, String postId, String currentPetId, String petName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _CommentBottomSheetWidget(
          postId: postId,
          currentPetId: currentPetId,
          petName: petName,
        );
      },
    );
  }
}

class _CommentBottomSheetWidget extends ConsumerStatefulWidget {
  final String postId;
  final String currentPetId;
  final String petName;

  const _CommentBottomSheetWidget({
    required this.postId,
    required this.currentPetId,
    required this.petName,
  });

  @override
  ConsumerState<_CommentBottomSheetWidget> createState() => _CommentBottomSheetWidgetState();
}

class _CommentBottomSheetWidgetState extends ConsumerState<_CommentBottomSheetWidget> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      ref.read(feedProvider.notifier).addComment(
            widget.postId,
            widget.currentPetId,
            widget.petName,
            text,
          );
      _commentController.clear();
      // Remove Focus
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPosts = ref.watch(feedProvider);
    // Find post to get reactive updates
    final post = allPosts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => allPosts.first, // Fallback safely
    );

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
          
          // Display the Comments List
          SizedBox(
            height: 300,
            child: post.comments.isEmpty
                ? const Center(child: Text('No comments yet. Start the conversation!', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      // Use a generic colored avatar based on name length for variation
                      final List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple];
                      final Color bg = colors[comment.petName.length % colors.length];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: bg.withOpacity(0.2),
                          child: Text(comment.petName[0].toUpperCase(), style: TextStyle(color: bg, fontWeight: FontWeight.bold)),
                        ),
                        title: Row(
                          children: [
                            Text(comment.petName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const Spacer(),
                            Text('Just now', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)), // Mocked Time
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(comment.text, style: const TextStyle(color: Colors.black87, fontSize: 14)),
                        ),
                      );
                    },
                  ),
          ),
          
          // Comment Input
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.blue),
                        onPressed: _submitComment,
                      ),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
