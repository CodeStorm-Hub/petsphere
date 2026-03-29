import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import 'pet_avatar.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String currentPetId;
  final VoidCallback onLikeToggle;
  final VoidCallback onCommentIconTap;

  const PostCard({
    super.key,
    required this.post,
    required this.currentPetId,
    required this.onLikeToggle,
    required this.onCommentIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = post.likedByPetIds.contains(currentPetId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              PetAvatar(imageUrl: post.pet.profileImageUrl, hasStory: true),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post.pet.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
        ),
        
        // Image
        AspectRatio(
          aspectRatio: 1, // Square image
          child: Image.network(
            post.mediaUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.error, color: Colors.grey),
            ),
          ),
        ),
        
        // Actions
        Row(
          children: [
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.black87,
              ),
              onPressed: onLikeToggle,
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: onCommentIconTap,
            ),
            IconButton(
              icon: const Icon(Icons.send_outlined),
              onPressed: () {},
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {},
            ),
          ],
        ),
        
        // Likes
        if (post.likedByPetIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '${post.likedByPetIds.length} likes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          
        // Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87),
              children: [
                TextSpan(
                  text: '${post.pet.name} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: post.caption),
              ],
            ),
          ),
        ),
        
        // Comments Preview
        if (post.comments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: InkWell(
              onTap: onCommentIconTap,
              child: Text(
                'View all ${post.comments.length} comments',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          
        const SizedBox(height: 16),
      ],
    );
  }
}
