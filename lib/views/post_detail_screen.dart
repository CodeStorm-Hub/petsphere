import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/post_model.dart';
import 'components/post_card.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    final activePet = ref.watch(activePetProvider);
    final currentPetId = activePet?.id ?? '';
    final userId = ref.watch(authProvider).user?.id ?? '';

    final idx = feedState.posts.indexWhere((p) => p.id == postId);
    if (idx < 0) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Post not found')),
      );
    }

    final post = feedState.posts[idx];
    final isOwnPost = post.pet.userId == userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(post.pet.name),
        actions: [
          if (isOwnPost)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete Post',
              onPressed: () => _confirmDelete(context, ref, post),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              PostCard(
              post: post,
              currentPetId: currentPetId,
              onLikeToggle: () {
                ref.read(feedProvider.notifier).toggleLike(post.id, currentPetId);
              },
              onCommentIconTap: () =>
                  _showCommentSheet(context, post.id, currentPetId, activePet?.name ?? ''),
              onShareIconTap: () => _showShareSheet(context, post.id),
              onPetTap: () {
                ref.read(profilePetNavigationProvider.notifier).navigateTo(post.pet.id);
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Row(
                    children: [
                      const Text('Comments',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        '${post.comments.length}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (post.comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No comments yet. Start the conversation!',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ),
                    )
                  else
                    ...post.comments.map((comment) {
                      final ago = _timeAgo(comment.createdAt);
                      final colors = [
                        Colors.red, Colors.blue, Colors.green,
                        Colors.orange, Colors.purple,
                      ];
                      final bg = colors[comment.petName.length % colors.length];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: bg.withAlpha(38),
                              child: Text(
                                comment.petName.isNotEmpty
                                    ? comment.petName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: bg),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(comment.petName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      const SizedBox(width: 8),
                                      Text(ago,
                                          style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(comment.text,
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  static String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PostModel post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Post'),
        content: const Text(
            'Are you sure you want to delete this post? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await ref.read(feedProvider.notifier).deletePost(post.id);
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Post deleted'),
                      backgroundColor: const Color(0xFF81C784),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to delete post'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context, String postId) {
    final shareLink = 'https://petsphere.app/post/$postId';
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withAlpha(76),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Share Post',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withAlpha(26),
                  ),
                  child: Icon(Icons.link, color: colorScheme.primary),
                ),
                title: const Text('Copy Link'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: shareLink));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Link copied to clipboard!'),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor:
                          Theme.of(context).snackBarTheme.backgroundColor,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.secondary.withAlpha(26),
                  ),
                  child: Icon(Icons.chat_bubble_outline, color: colorScheme.secondary),
                ),
                title: const Text('Send in Message'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/messages');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentSheet(
      BuildContext context, String postId, String currentPetId, String petName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _CommentSheet(
          postId: postId,
          currentPetId: currentPetId,
          petName: petName,
        );
      },
    );
  }
}

class _CommentSheet extends ConsumerStatefulWidget {
  final String postId;
  final String currentPetId;
  final String petName;

  const _CommentSheet({
    required this.postId,
    required this.currentPetId,
    required this.petName,
  });

  @override
  ConsumerState<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<_CommentSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(feedProvider.notifier).addComment(
            widget.postId,
            widget.currentPetId,
            widget.petName,
            text,
          );
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const Text('Add Comment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Color(0xFFFF8A65)),
                      onPressed: _submit,
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
