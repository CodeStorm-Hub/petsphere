import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/post_model.dart';
import '../utils/pet_navigation.dart';
import 'components/post_card.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(postByIdProvider(postId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: colorScheme.error),
                const SizedBox(height: 12),
                Text('Could not load post',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(postByIdProvider(postId)),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (post) {
        if (post == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Post not found')),
          );
        }
        return _PostDetailContent(post: post);
      },
    );
  }
}

class _PostDetailContent extends ConsumerWidget {
  final PostModel post;

  const _PostDetailContent({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final activePet = ref.watch(activePetProvider);
    final currentPetId = activePet?.id ?? '';
    final userId = ref.watch(authProvider).user?.id ?? '';
    final isOwnPost = post.pet.userId == userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(post.pet.name),
        actions: [
          if (isOwnPost)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              tooltip: 'Delete Post',
              onPressed: () => _confirmDelete(context, ref, post),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(feedProvider.notifier).refresh();
          ref.invalidate(postByIdProvider(post.id));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              PostCard(
                post: post,
                currentPetId: currentPetId,
                onLikeToggle: () {
                  ref
                      .read(feedProvider.notifier)
                      .toggleLike(post.id, currentPetId);
                },
                onCommentIconTap: () => _showCommentSheet(
                    context, post.id, currentPetId, activePet?.name ?? ''),
                onShareIconTap: () => _sharePost(context, post),
                onPetTap: () {
                  Navigator.pop(context);
                  openPetProfile(
                    context,
                    ref,
                    petId: post.pet.id,
                    petUserId: post.pet.userId,
                  );
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
                            color: colorScheme.onSurfaceVariant,
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
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      ...post.comments.map((comment) {
                        final ago = _timeAgo(comment.createdAt);
                        final colors = [
                          colorScheme.error,
                          Colors.blue,
                          colorScheme.secondary,
                          Colors.orange,
                          Colors.purple,
                        ];
                        final bg =
                            colors[comment.petName.length % colors.length];
                        void openCommenter() => openPetProfile(
                              context,
                              ref,
                              petId: comment.petId,
                            );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: openCommenter,
                                child: CircleAvatar(
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
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: openCommenter,
                                          child: Text(comment.petName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13)),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(ago,
                                            style: TextStyle(
                                                color: colorScheme.onSurfaceVariant,
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
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sharePost(BuildContext context, PostModel post) {
    final link = 'https://petsphere.app/post/${post.id}';
    final caption = post.caption.isNotEmpty ? '"${post.caption}"\n\n' : '';
    SharePlus.instance.share(
      ShareParams(
        text: 'Check out ${post.pet.name} on PetSphere! $caption$link',
        subject: 'PetSphere — ${post.pet.name}',
      ),
    );
  }

  void _showCommentSheet(BuildContext context, String postId,
      String currentPetId, String petName) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.onPrimary,
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
