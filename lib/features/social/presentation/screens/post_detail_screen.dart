import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/social/presentation/controllers/feed_controller.dart';
import 'package:petfolio/features/social/presentation/widgets/post_card.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isPostingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showCommentSheet(BuildContext context, String postId, String petId, String petName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      if (_commentController.text.trim().isEmpty) return;
                      setState(() => _isPostingComment = true);
                      await ref.read(feedProvider.notifier).addComment(
                        postId,
                        petId,
                        petName,
                        _commentController.text.trim(),
                      );
                      if (ctx.mounted) {
                        _commentController.clear();
                        Navigator.pop(ctx);
                      }
                      if (mounted) setState(() => _isPostingComment = false);
                    },
                    child: _isPostingComment
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sharePost(String postId, String petName, String caption) {
    SharePlus.instance.share(ShareParams(text: 'Check out this post by $petName on PetFolio: $caption'));
  }

  void _showEditDialog(BuildContext context, String postId, String currentCaption) {
    final editController = TextEditingController(text: currentCaption);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: 'Update your caption...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (editController.text.trim().isEmpty) return;
              await ref.read(feedProvider.notifier).updatePost(
                postId: postId,
                caption: editController.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String postId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref.read(feedProvider.notifier).deletePost(postId);
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(
      feedProvider.select((state) {
        for (final item in state.posts) {
          if (item.id == widget.postId) return item;
        }
        return null;
      }),
    );

    if (post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Post not found')),
      );
    }

    final activePet = ref.watch(activePetProvider);
    final currentPetId = activePet?.id ?? '';
    final userId = ref.watch(authProvider).user?.id ?? '';
    final isOwnPost = post.pet.userId == userId;

    return Scaffold(
      appBar: AppBar(title: Text(post.pet.name)),
      body: SingleChildScrollView(
        child: PostCard(
          post: post,
          currentPetId: currentPetId,
          onLikeToggle: () =>
              ref.read(feedProvider.notifier).toggleLike(post.id, currentPetId),
          onCommentIconTap: () => _showCommentSheet(
            context,
            post.id,
            currentPetId,
            activePet?.name ?? 'Your Pet',
          ),
          onShareIconTap: () => _sharePost(post.id, post.pet.name, post.caption),
          onPetTap: () => context.push(AppRoutes.petProfileById(post.pet.id)),
          onEdit: isOwnPost ? () => _showEditDialog(context, post.id, post.caption) : null,
          onDelete: isOwnPost ? () => _showDeleteConfirmation(context, post.id) : null,
        ),
      ),
    );
  }
}
