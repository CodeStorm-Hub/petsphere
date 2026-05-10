import 'package:flutter/material.dart';
import 'package:petfolio/features/social/data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String currentPetId;
  final VoidCallback onLikeToggle;
  final VoidCallback onCommentIconTap;
  final VoidCallback onShareIconTap;
  final VoidCallback? onPetTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.currentPetId,
    required this.onLikeToggle,
    required this.onCommentIconTap,
    required this.onShareIconTap,
    this.onPetTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(post.pet.name),
              subtitle: Text(post.caption),
              onTap: onPetTap,
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onLikeToggle,
                  icon: Icon(
                    post.likedByPetIds.contains(currentPetId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: theme.colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: onCommentIconTap,
                  icon: const Icon(Icons.comment_outlined),
                ),
                IconButton(
                  onPressed: onShareIconTap,
                  icon: const Icon(Icons.share_outlined),
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
