import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:petfolio/features/social/data/models/post_model.dart';
import 'package:petfolio/features/social/presentation/widgets/post_media.dart';
import 'package:petfolio/core/widgets/brand_logo.dart';
import 'package:petfolio/core/utils/media_utils.dart';

class PostCard extends StatelessWidget {

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
  final PostModel post;
  final String currentPetId;
  final VoidCallback onLikeToggle;
  final VoidCallback onCommentIconTap;
  final VoidCallback onShareIconTap;
  final VoidCallback? onPetTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLiked = post.likedByPetIds.contains(currentPetId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onPetTap,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: post.pet.profileImageUrl.isNotEmpty
                          ? NetworkImage(post.pet.profileImageUrl)
                          : null,
                      child: post.pet.profileImageUrl.isEmpty
                          ? const BrandLogo(customSize: 18)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: onPetTap,
                          child: Text(
                            post.pet.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd().format(post.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: colorScheme.onSurfaceVariant),
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit Post'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline, color: Colors.red),
                              title: Text('Delete Post', style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            // Caption (if present)
            if (post.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  post.caption,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                  ),
                ),
              ),

            // Media
            if (post.mediaUrl.isNotEmpty)
              PostMedia(
                mediaUrl: post.mediaUrl,
                isVideo: post.mediaType == PostMediaType.video,
                aspectRatio: 4 / 5, // Instagram-style portrait aspect ratio
              ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onLikeToggle,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                    ),
                  ).animate(target: isLiked ? 1 : 0).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.2, 1.2),
                        duration: 200.ms,
                        curve: Curves.easeOutBack,
                      ).then().scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1)),
                  Text(
                    '${post.likedByPetIds.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onCommentIconTap,
                    icon: Icon(Icons.chat_bubble_outline, color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${post.commentCount}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onShareIconTap,
                    icon: Icon(Icons.share_outlined, color: colorScheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}
