import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:petfolio/core/widgets/brand_logo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:petfolio/features/messaging/presentation/controllers/chat_controller.dart';
import 'package:petfolio/features/social/presentation/controllers/feed_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:petfolio/features/notifications/data/notification_repository.dart';
import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/social/data/models/post_model.dart';
import 'package:petfolio/features/social/data/models/story_model.dart';
import 'package:petfolio/core/theme/spacing.dart';
import 'package:petfolio/features/social/utils/post_actions.dart';
import 'package:petfolio/core/utils/pet_navigation.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import 'package:petfolio/features/social/presentation/widgets/post_card.dart';
import 'package:petfolio/core/utils/layout_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petfolio/core/widgets/skeleton_loader.dart';

// Maximum feed column width on wide screens (tablets, foldables, web).
// Below this, the feed is full-width edge-to-edge like the Instagram phone app.
const double _kFeedMaxWidth = 560.0;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePetId = ref.watch(activePetProvider.select((p) => p?.id ?? ''));
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Pet Lover';
    final myPets = ref.watch(petProvider.select((s) => s.myPets));
    final feedPosts = ref.watch(feedProvider.select((s) => s.posts));
    final feedLoading = ref.watch(feedProvider.select((s) => s.isLoading));
    final feedError = ref.watch(feedProvider.select((s) => s.error));
    final feedStories = ref.watch(feedProvider.select((s) => s.visibleStories));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final firstName = userName.split(' ').first;
    final greeting = _timeBasedGreeting();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
          ),
        ),
        titleSpacing: 16,
        title: const BrandLogo(size: BrandLogoSize.small, withText: true),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            tooltip: 'New Post',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => context.push(AppRoutes.createPost),
          ),
          _NotificationIconButton(onTap: () => context.push(AppRoutes.notifications)),
          _MessageIconButton(onTap: () => context.push(AppRoutes.messages)),
          const SizedBox(width: 4),
        ],
      ),
      body: PetFolioGradientBackground(
        child: _buildBody(
          context,
          ref,
          feedPosts,
          feedLoading,
          feedError,
          feedStories,
          activePetId,
          firstName,
          greeting,
          myPets,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<PostModel> posts,
    bool isLoading,
    String? error,
    List<StoryModel> stories,
    String currentPetId,
    String userName,
    String greeting,
    List<PetModel> myPets,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;
    final navSpace = isTablet ? 24.0 : bottomNavSpaceFor(context);

    Widget centerWrap(Widget child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final feedWidth = math.min(constraints.maxWidth, _kFeedMaxWidth);
          return Center(
            child: SizedBox(width: feedWidth, child: child),
          );
        },
      );
    }

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.only(bottom: navSpace),
        child: centerWrap(const FeedSkeletonLoader()),
      );
    }

    if (error != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: navSpace),
        child: Center(
          child: GlassCard(
            margin: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: AppSpacing.md),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: () => ref.read(feedProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: centerWrap(
        CustomScrollView(
          slivers: [
            // ── Personalized Greeting ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $userName!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontFamily: 'Playfair Display',
                      ),
                    ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      'See what your favorite pets are up to today.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'DM Sans',
                      ),
                    ).animate().fade(delay: 200.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),

            // ── Stories row (Instagram-style) ────────────────────────
            if (myPets.isNotEmpty)
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: _StoriesRow(
                    pets: myPets,
                    stories: stories,
                    currentPetId: currentPetId,
                    onCreateStory: () => _openCreateStoryForPet(
                      context,
                      myPets,
                      currentPetId: currentPetId,
                    ),
                    onStoryTap: (petId) => context.push(AppRoutes.storyByPetId(petId)),
                    onYourStoryTap: (petId) => _onYourStoryTap(
                      context,
                      myPets,
                      currentPetId: currentPetId,
                      storyPetId: petId,
                    ),
                  ),
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
            if (posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: navSpace),
                  child: PetfolioEmptyState(
                    icon: Icons.photo_camera_outlined,
                    title: 'No posts yet',
                    message: 'Share your first moment.',
                    buttonText: 'Create Post',
                    buttonIcon: Icons.add_a_photo_outlined,
                    onButtonPressed: () => context.push(AppRoutes.createPost),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.only(bottom: navSpace),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = posts[index];
                    return RepaintBoundary(
                      child: PostCard(
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
                        onEdit:
                            post.pet.userId == ref.read(authProvider).user?.id
                            ? () => showEditPostDialog(context, ref, post)
                            : null,
                        onDelete:
                            post.pet.userId == ref.read(authProvider).user?.id
                            ? () => showDeletePostDialog(context, ref, post)
                            : null,
                      ),
                    );
                  }, childCount: posts.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Returns a time-appropriate greeting based on the current local hour.
  String _timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _showShareSheet(
    BuildContext context,
    WidgetRef ref,
    PostModel post,
  ) async {
    final shareLink = 'https://petfolio.app/post/${post.id}';

    final result = await SharePlus.instance.share(
      ShareParams(
        text: 'Check out this pet on PetFolio!\n$shareLink',
        subject: 'PetFolio',
      ),
    );

    if (result.status == ShareResultStatus.success) {
      try {
        final authedUser = ref.read(authProvider).user;
        if (authedUser != null && post.pet.userId != authedUser.id) {
          unawaited(notificationRepository.sendNotification(
            targetUserId: post.pet.userId,
            title: 'Post Shared',
            body: 'Someone shared your post!',
            type: 'post_share',
            entityType: 'post',
            entityId: post.id,
          ));
        }
      } catch (_) {}
    }
  }

  Future<void> _openCreateStoryForPet(
    BuildContext context,
    List<PetModel> myPets, {
    required String currentPetId,
  }) async {
    if (myPets.isEmpty) {
      await context.push(AppRoutes.addPet);
      return;
    }

    if (myPets.length == 1) {
      await context.push(AppRoutes.createStoryByPetId(myPets.first.id));
      return;
    }

    final selectedPetId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final mediaQuery = MediaQuery.of(sheetContext);
        final maxSheetHeight = mediaQuery.size.height * 0.78;

        return Padding(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: colorScheme.outline.withAlpha(80),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        height: maxSheetHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Builder(
                                builder: (context) {
                                  final colorScheme = Theme.of(
                                    context,
                                  ).colorScheme;
                                  return Container(
                                    width: 44,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: colorScheme.outline.withAlpha(100),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Builder(
                              builder: (context) {
                                final colorScheme = Theme.of(
                                  context,
                                ).colorScheme;
                                return Text(
                                  'Post story as',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            Builder(
                              builder: (context) {
                                final colorScheme = Theme.of(
                                  context,
                                ).colorScheme;
                                return Text(
                                  'Choose which pet should post this story.',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.builder(
                                itemCount: myPets.length,
                                itemBuilder: (context, index) {
                                  final pet = myPets[index];
                                  final isCurrent = pet.id == currentPetId;
                                  final colorScheme = Theme.of(
                                    context,
                                  ).colorScheme;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () =>
                                        Navigator.pop(sheetContext, pet.id),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          colorScheme.surfaceContainerHighest,
                                      backgroundImage:
                                          pet.profileImageUrl.isNotEmpty
                                          ? CachedNetworkImageProvider(
                                              pet.profileImageUrl,
                                            )
                                          : null,
                                      child: pet.profileImageUrl.isEmpty
                                          ? Text(
                                              pet.name.isNotEmpty
                                                  ? pet.name[0].toUpperCase()
                                                  : '?',
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      pet.name,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      pet.breed,
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: isCurrent
                                        ? Icon(
                                            Icons.check_circle,
                                            color: colorScheme.primary,
                                          )
                                        : Icon(
                                            Icons.chevron_right,
                                            color: colorScheme.outline
                                                .withAlpha(100),
                                          ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted || selectedPetId == null) return;
    await context.push(AppRoutes.createStoryByPetId(selectedPetId));
  }

  Future<void> _onYourStoryTap(
    BuildContext context,
    List<PetModel> myPets, {
    required String currentPetId,
    required String? storyPetId,
  }) async {
    if (storyPetId == null) {
      await _openCreateStoryForPet(context, myPets, currentPetId: currentPetId);
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colorScheme.outline.withAlpha(80)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withAlpha(100),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your story',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose what you want to do.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.visibility_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    'View story',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'view'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    'Post story',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'post'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || action == null) return;
    if (action == 'view') {
      await context.push(AppRoutes.storyByPetId(storyPetId));
      return;
    }

    await _openCreateStoryForPet(context, myPets, currentPetId: currentPetId);
  }

  void _showCommentSheet(
    BuildContext context,
    String postId,
    String currentPetId,
    String petName,
  ) {
    showModalBottomSheet<void>(
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

  const _CommentBottomSheetWidget({
    required this.postId,
    required this.currentPetId,
    required this.petName,
  });
  final String postId;
  final String currentPetId;
  final String petName;

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
      ref
          .read(feedProvider.notifier)
          .addComment(widget.postId, widget.currentPetId, widget.petName, text);
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
            Text(
              'Post not found',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
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
          const Text(
            'Comments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Divider(color: colorScheme.outline.withAlpha(40)),
          SizedBox(
            height: 300,
            child: post.comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 40,
                          color: colorScheme.outline.withAlpha(80),
                        ),
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
                      final commentColorScheme = Theme.of(context).colorScheme;
                      final colors = [
                        commentColorScheme.primary,
                        commentColorScheme.secondary,
                        commentColorScheme.tertiary,
                        commentColorScheme.primary.withAlpha(200),
                        commentColorScheme.secondary.withAlpha(200),
                      ];
                      final bg = colors[comment.petName.length % colors.length];

                      void openCommenter() {
                        Navigator.pop(context);
                        openPetProfile(context, ref, petId: comment.petId);
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: GestureDetector(
                          onTap: openCommenter,
                          child: CircleAvatar(
                            backgroundColor: bg.withAlpha(40),
                            child: Text(
                              comment.petName[0].toUpperCase(),
                              style: TextStyle(
                                color: bg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            GestureDetector(
                              onTap: openCommenter,
                              child: Text(
                                comment.petName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTimeAgo(comment.createdAt),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            comment.text,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        tooltip: 'Send',
                        icon: Icon(
                          Icons.send_rounded,
                          color: colorScheme.primary,
                        ),
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
// Renders active 24-hour stories plus the user's pets as horizontally scrolling
// story bubbles. The active pet is shown first as "Your story" with a + overlay.
// Sized intrinsically so it never overflows on any device or text scale.
class _StoriesRow extends StatelessWidget {

  const _StoriesRow({
    required this.pets,
    required this.stories,
    required this.currentPetId,
    required this.onCreateStory,
    required this.onStoryTap,
    required this.onYourStoryTap,
  });
  final List<PetModel> pets;
  final List<StoryModel> stories;
  final String currentPetId;
  final VoidCallback onCreateStory;
  final ValueChanged<String> onStoryTap;
  final ValueChanged<String?> onYourStoryTap;

  @override
  Widget build(BuildContext context) {
    final activePet = pets.firstWhere(
      (p) => p.id == currentPetId,
      orElse: () => pets.first,
    );
    final storyPetIds = stories.map((story) => story.pet.id).toSet();
    final myPetIds = pets.map((pet) => pet.id).toSet();
    final myStoryPets = <PetModel>[
      ...pets.where((pet) => storyPetIds.contains(pet.id)),
    ];
    final externalStoryPetsById = <String, PetModel>{};
    for (final story in stories) {
      if (!myPetIds.contains(story.pet.id)) {
        externalStoryPetsById[story.pet.id] = story.pet;
      }
    }
    final activePetHasStory = storyPetIds.contains(activePet.id);
    final primaryMyStoryPet = activePetHasStory
        ? activePet
        : (myStoryPets.isNotEmpty ? myStoryPets.first : null);
    final additionalMyStoryPets = myStoryPets
        .where((pet) => pet.id != primaryMyStoryPet?.id)
        .toList();
    final followedStoryPets = externalStoryPetsById.values.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StoryItem(
            imageUrl: (primaryMyStoryPet ?? activePet).profileImageUrl,
            label: 'Your story',
            ringStyle: primaryMyStoryPet != null
                ? _RingStyle.gradient
                : _RingStyle.none,
            badge: _StoryBadge.plus,
            onBadgeTap: onCreateStory,
            onTap: () => onYourStoryTap(primaryMyStoryPet?.id),
          ),
          for (final pet in additionalMyStoryPets)
            _StoryItem(
              imageUrl: pet.profileImageUrl,
              label: pet.name,
              ringStyle: _RingStyle.gradient,
              onTap: () => onStoryTap(pet.id),
            ),
          for (final pet in followedStoryPets)
            _StoryItem(
              imageUrl: pet.profileImageUrl,
              label: pet.name,
              ringStyle: _RingStyle.gradient,
              onTap: () => onStoryTap(pet.id),
            ),
        ],
      ),
    );
  }
}

enum _RingStyle { none, gradient, dashed }

enum _StoryBadge { none, plus }

class _StoryItem extends StatelessWidget {

  const _StoryItem({
    required this.imageUrl,
    required this.label,
    required this.ringStyle,
    this.badge = _StoryBadge.none,
    required this.onTap,
    this.onBadgeTap,
  });
  final String imageUrl;
  final String label;
  final _RingStyle ringStyle;
  final _StoryBadge badge;
  final VoidCallback onTap;
  final VoidCallback? onBadgeTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const innerRadius = 30.0;

    final Widget avatar = CircleAvatar(
      radius: innerRadius,
      backgroundColor: colorScheme.surfaceContainerHighest,
      backgroundImage: imageUrl.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl)
          : null,
      child: imageUrl.isEmpty
          ? BrandLogo(
              customSize: innerRadius * 0.8,
              color: colorScheme.onSurfaceVariant,
            )
          : null,
    );

    Widget ringed;
    switch (ringStyle) {
      case _RingStyle.gradient:
        ringed = Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withAlpha(180),
                colorScheme.secondary,
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
          child: avatar,
        );
        break;
      case _RingStyle.none:
        ringed = Padding(padding: const EdgeInsets.all(4.5), child: avatar);
    }

    if (badge == _StoryBadge.plus) {
      ringed = Stack(
        clipBehavior: Clip.none,
        children: [
          ringed,
          Positioned(
            right: 0,
            bottom: 0,
            child: Semantics(
              button: true,
              label: 'Add story',
              child: GestureDetector(
                onTap: onBadgeTap,
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
            ),
          ),
        ],
      );
    }

    return Semantics(
          button: true,
          label: 'Story by $label',
          child: GestureDetector(
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
          ),
        )
        .animate()
        .fade(duration: 400.ms)
        .slideX(
          begin: 0.1,
          end: 0,
          curve: Curves.easeOutCubic,
          duration: 400.ms,
        );
  }
}

/// Simple dashed circular border for the "Add Pet" story bubble.
class DottedCircle extends StatelessWidget {

  const DottedCircle({
    super.key,
    required this.child,
    required this.color,
    this.padding = 4,
  });
  final Widget child;
  final Color color;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color: color),
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});
  final Color color;

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
    const segment = (2 * math.pi) / dashes;
    const stroke = segment * (1 - gapFraction);

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
  const _NotificationIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(notificationProvider.select((s) => s.unreadCount));

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
              child: ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
  const _MessageIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(chatProvider.select((s) => s.totalUnread));

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
              child: ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: onTap,
    );
  }
}

