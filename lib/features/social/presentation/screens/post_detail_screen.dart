import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/social/presentation/controllers/feed_controller.dart';
import 'package:petfolio/features/social/presentation/widgets/post_card.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(
      feedProvider.select((state) {
        for (final item in state.posts) {
          if (item.id == postId) return item;
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
          onCommentIconTap: () {},
          onShareIconTap: () {},
          onPetTap: () {},
          onEdit: isOwnPost ? () {} : null,
          onDelete: isOwnPost ? () {} : null,
        ),
      ),
    );
  }
}
