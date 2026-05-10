import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petsphere/features/social/data/models/post_model.dart';
import 'package:petsphere/features/social/presentation/controllers/feed_controller.dart';

void showEditPostDialog(BuildContext context, WidgetRef ref, PostModel post) {
  final controller = TextEditingController(text: post.caption);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit Post'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Enter new caption...'),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final success = await ref
                .read(feedProvider.notifier)
                .updatePost(postId: post.id, caption: controller.text);
            if (ctx.mounted) {
              Navigator.pop(ctx);
              if (success) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post updated!')));
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void showDeletePostDialog(
  BuildContext context,
  WidgetRef ref,
  PostModel post, {
  VoidCallback? onDeleteSuccess,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Post'),
      content: const Text(
        'Are you sure you want to delete this post? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final success = await ref
                .read(feedProvider.notifier)
                .deletePost(post.id);
            if (ctx.mounted) {
              Navigator.pop(ctx);
              if (success) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post deleted.')));
                onDeleteSuccess?.call();
              }
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
