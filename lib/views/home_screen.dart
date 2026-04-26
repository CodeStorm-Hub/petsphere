import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../repositories/notification_repository.dart';
import '../models/pet_model.dart';
import '../models/post_model.dart';
import '../utils/pet_navigation.dart';
import 'components/post_card.dart';
import 'main_layout.dart' show bottomNavSpaceFor;

// Maximum feed column width on wide screens (tablets, foldables, web).
// Below this, the feed is full-width edge-to-edge like the Instagram phone app.
const double _kFeedMaxWidth = 560.0;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    final activePet = ref.watch(activePetProvider);
    final currentPetId = activePet?.id ?? '';
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Pet Lover';
    final myPets = ref.watch(petProvider).myPets;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final firstName = userName.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.pets, size: 22, color: Color(0xFF99472C)),
            const SizedBox(width: 8),
            Text(
              'Atelier',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New Post',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => context.push('/create_post'),
          ),
          _NotificationIconButton(
            onTap: () => context.push('/notifications'),
          ),
          _MessageIconButton(
            onTap: () => context.push('/messages'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(
          context, ref, feedState, currentPetId, firstName, myPets),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    FeedState feedState,
    String currentPetId,
    String userName,
    List<PetModel> myPets,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navSpace = bottomNavSpaceFor(context);

    Widget centerWrap(Widget child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(constraints.maxWidth, _kFeedMaxWidth);
          return Center(
            child: SizedBox(width: width, child: child),
          );
        },
      );
    }

    if (feedState.isLoading) {
      return Padding(
        padding: EdgeInsets.only(bottom: navSpace),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (feedState.error != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: navSpace),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(feedState.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.read(feedProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: centerWrap(
        CustomScrollView(
          slivers: [
            // ── Stories row (Instagram-style) ────────────────────────
            if (myPets.isNotEmpty)
              SliverToBoxAdapter(
                child: _StoriesRow(
                  pets: myPets,
                  currentPetId: currentPetId,
                  onPetTap: (pet) => ref
                      .read(profilePetNavigationProvider.notifier)
                      .navigateTo(pet.id),
                  onAddPet: () => context.push('/add_pet'),
                ),
              ),

            // ── Hairline separator under stories ─────────────────────
            if (myPets.isNotEmpty)
              SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: colorScheme.outline.withAlpha(40),
                ),
              ),

            // ── Empty state ──────────────────────────────────────────
            if (feedState.posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: navSpace),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera_outlined,
                            size: 56, color: colorScheme.outline.withAlpha(120)),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Share your first moment.',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => context.push('/create_post'),
                          icon: const Icon(Icons.add_a_photo_outlined,
                              size: 18),
                          label: const Text('Create Post'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.only(bottom: navSpace),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = feedState.posts[index];
                      return PostCard(
                        post: post,
                        currentPetId: currentPetId,
                        onLikeToggle: () {
                          ref
                              .read(feedProvider.notifier)
                              .toggleLike(post.id, currentPetId);
                        },
                        onCommentIconTap: () {
                          _showCommentSheet(
                            context,
                            post.id,
                            currentPetId,
                            ref.read(activePetProvider)?.name ?? 'Unknown',
                          );
                        },
                        onShareIconTap: () =>
                            _showShareSheet(context, ref, post),
                        onPetTap: () => openPetProfile(
                          context,
                          ref,
                          petId: post.pet.id,
                          petUserId: post.pet.userId,
                        ),
                      );
                    },
                    childCount: feedState.posts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, WidgetRef ref, PostModel post) async {
    final shareLink = 'https://petsphere.app/post/${post.id}';
    
    final result = await SharePlus.instance.share(
      ShareParams(
        text: 'Check out this pet on PetSphere!\n$shareLink',
        subject: 'PetSphere',
      ),
    );

    if (result.status == ShareResultStatus.success) {
      try {
        final authedUser = ref.read(authProvider).user;
        if (authedUser != null && post.pet.userId != authedUser.id) {
          notificationRepository.sendNotification(
            targetUserId: post.pet.userId,
            title: 'Post Shared',
            body: 'Someone shared your post!',
            type: 'post_share',
            entityType: 'post',
            entityId: post.id,
          );
        }
      } catch (_) {}
    }
  }

  void _showCommentSheet(
      BuildContext context, String postId, String currentPetId, String petName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
  ConsumerState<_CommentBottomSheetWidget> createState() =>
      _CommentBottomSheetWidgetState();
}

class _CommentBottomSheetWidgetState
    extends ConsumerState<_CommentBottomSheetWidget> {
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
      FocusScope.of(context).unfocus();
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Safely find post — use try/catch to prevent StateError
    final postIndex = feedState.posts.indexWhere((p) => p.id == widget.postId);
    if (postIndex == -1) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text('Post not found',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    final post = feedState.posts[postIndex];

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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withAlpha(76),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Comments',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Divider(color: colorScheme.outline.withAlpha(40)),
          SizedBox(
            height: 300,
            child: post.comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 40, color: colorScheme.outline.withAlpha(80)),
                        const SizedBox(height: 8),
                        Text(
                          'No comments yet.\nStart the conversation!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      final colors = [
                        const Color(0xFFE57373),
                        const Color(0xFF4FC3F7),
                        const Color(0xFF81C784),
                        const Color(0xFFFF8A65),
                        const Color(0xFFBA68C8),
                      ];
                      final bg = colors[comment.petName.length % colors.length];

                      void openCommenter() {
                        Navigator.pop(context);
                        openPetProfile(
                          context,
                          ref,
                          petId: comment.petId,
                        );
                      }

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 4),
                        leading: GestureDetector(
                          onTap: openCommenter,
                          child: CircleAvatar(
                            backgroundColor: bg.withAlpha(40),
                            child: Text(
                              comment.petName[0].toUpperCase(),
                              style: TextStyle(
                                  color: bg, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            GestureDetector(
                              onTap: openCommenter,
                              child: Text(comment.petName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ),
                            const Spacer(),
                            Text(
                              _formatTimeAgo(comment.createdAt),
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(comment.text,
                              style: TextStyle(
                                  color: colorScheme.onSurface, fontSize: 14)),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send_rounded,
                            color: colorScheme.primary),
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

// ── Instagram-style stories row ────────────────────────────────────────────
//
// Renders the user's pets as horizontally scrolling story bubbles. The active
// pet is shown first as "Your story" (with a + overlay so the user can post
// their own moment); other pets get the iconic multi-color gradient ring.
// Sized intrinsically so it never overflows on any device or text scale.
class _StoriesRow extends StatelessWidget {
  final List<PetModel> pets;
  final String currentPetId;
  final ValueChanged<PetModel> onPetTap;
  final VoidCallback onAddPet;

  const _StoriesRow({
    required this.pets,
    required this.currentPetId,
    required this.onPetTap,
    required this.onAddPet,
  });

  @override
  Widget build(BuildContext context) {
    final activePet = pets.firstWhere(
      (p) => p.id == currentPetId,
      orElse: () => pets.first,
    );
    final others = pets.where((p) => p.id != activePet.id).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StoryItem(
            imageUrl: activePet.profileImageUrl,
            label: 'Your story',
            ringStyle: _RingStyle.none,
            badge: _StoryBadge.plus,
            onTap: onAddPet,
          ),
          for (final pet in others)
            _StoryItem(
              imageUrl: pet.profileImageUrl,
              label: pet.name,
              ringStyle: _RingStyle.gradient,
              onTap: () => onPetTap(pet),
            ),
          _StoryItem(
            imageUrl: '',
            label: 'Add Pet',
            ringStyle: _RingStyle.dashed,
            iconOverride: Icons.add,
            onTap: onAddPet,
          ),
        ],
      ),
    );
  }
}

enum _RingStyle { none, gradient, dashed }

enum _StoryBadge { none, plus }

class _StoryItem extends StatelessWidget {
  final String imageUrl;
  final String label;
  final _RingStyle ringStyle;
  final _StoryBadge badge;
  final IconData? iconOverride;
  final VoidCallback onTap;

  const _StoryItem({
    required this.imageUrl,
    required this.label,
    required this.ringStyle,
    this.badge = _StoryBadge.none,
    this.iconOverride,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const innerRadius = 30.0;

    Widget avatar = CircleAvatar(
      radius: innerRadius,
      backgroundColor: colorScheme.surfaceContainerHighest,
      backgroundImage:
          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      child: imageUrl.isEmpty
          ? Icon(
              iconOverride ?? Icons.pets,
              size: innerRadius * 0.8,
              color: colorScheme.onSurfaceVariant,
            )
          : null,
    );

    Widget ringed;
    switch (ringStyle) {
      case _RingStyle.gradient:
        ringed = Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFD4845A),
                Color(0xFFB86A44),
                Color(0xFF4A7C59),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            padding: const EdgeInsets.all(2),
            child: avatar,
          ),
        );
        break;
      case _RingStyle.dashed:
        ringed = DottedCircle(
          color: colorScheme.outline.withAlpha(140),
          padding: 4,
          child: avatar,
        );
        break;
      case _RingStyle.none:
        ringed = Padding(
          padding: const EdgeInsets.all(4.5),
          child: avatar,
        );
    }

    if (badge == _StoryBadge.plus) {
      ringed = Stack(
        clipBehavior: Clip.none,
        children: [
          ringed,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 14,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ringed,
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple dashed circular border for the "Add Pet" story bubble.
class DottedCircle extends StatelessWidget {
  final Widget child;
  final Color color;
  final double padding;

  const DottedCircle({
    super.key,
    required this.child,
    required this.color,
    this.padding = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color: color),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final radius = math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const dashes = 28;
    const gapFraction = 0.45;
    final segment = (2 * math.pi) / dashes;
    final stroke = segment * (1 - gapFraction);

    for (var i = 0; i < dashes; i++) {
      final start = i * segment;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1),
        start,
        stroke,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

class _NotificationIconButton extends ConsumerWidget {
  final VoidCallback onTap;
  const _NotificationIconButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread =
        ref.watch(notificationProvider.select((s) => s.unreadCount));

    return IconButton(
      tooltip: unread > 0 ? 'Notifications ($unread unread)' : 'Notifications',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.favorite_border),
          if (unread > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: onTap,
    );
  }
}

class _MessageIconButton extends ConsumerWidget {
  final VoidCallback onTap;
  const _MessageIconButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread =
        ref.watch(notificationProvider.select((s) => s.unreadMessageCount));

    return IconButton(
      tooltip: unread > 0 ? 'Messages ($unread unread)' : 'Messages',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.send_outlined),
          if (unread > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: onTap,
    );
  }
}

