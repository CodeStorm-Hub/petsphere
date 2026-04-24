import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import 'components/post_card.dart';

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
              'The Nurtured Atelier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          _NotificationIconButton(
            onTap: () => context.push('/notifications'),
          ),
          IconButton(
            tooltip: 'Messages',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('/messages'),
          ),
        ],
      ),
      body: _buildBody(context, ref, feedState, currentPetId, firstName, myPets),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    FeedState feedState,
    String currentPetId,
    String userName,
    List myPets,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (feedState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feedState.error != null) {
      return Center(
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
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // ── Personalized greeting + search ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover your next furry friend or share a tail-wagging moment.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E1DA),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: () {},
                      decoration: InputDecoration(
                        hintText: 'Search breeds, moments, or friends...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withAlpha(160),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                        fillColor: Colors.transparent,
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Category chips ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _CategoryChipsRow(),
          ),

          // Pet avatars row
          if (myPets.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: myPets.length + 1, // +1 for "Add" button
                  itemBuilder: (context, index) {
                    if (index == myPets.length) {
                      // "Add Pet" button
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => context.push('/add_pet'),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.outline.withAlpha(60),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Pet',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final pet = myPets[index];
                    final isActive = pet.id == currentPetId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(profilePetNavigationProvider.notifier).navigateTo(pet.id);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isActive
                                    ? LinearGradient(
                                        colors: [
                                          colorScheme.primary,
                                          colorScheme.tertiary,
                                        ],
                                      )
                                    : null,
                                border: !isActive
                                    ? Border.all(
                                        color: colorScheme.outline.withAlpha(60),
                                        width: 1.5,
                                      )
                                    : null,
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: colorScheme.surface,
                                backgroundImage: pet.profileImageUrl.isNotEmpty
                                    ? NetworkImage(pet.profileImageUrl)
                                    : null,
                                child: pet.profileImageUrl.isEmpty
                                    ? Icon(Icons.pets,
                                        size: 20,
                                        color: colorScheme.onSurfaceVariant)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              child: Text(
                                pet.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                  color: isActive
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Divider
          if (myPets.isNotEmpty)
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                color: colorScheme.outline.withAlpha(30),
              ),
            ),

          // Empty state
          if (feedState.posts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 64, color: colorScheme.outline.withAlpha(80)),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet!\nBe the first to share.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.push('/create_post'),
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: const Text('Create Post'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = feedState.posts[index];
                  return PostCard(
                    post: post,
                    currentPetId: currentPetId,
                    onLikeToggle: () {
                      ref.read(feedProvider.notifier).toggleLike(post.id, currentPetId);
                    },
                    onCommentIconTap: () {
                      _showCommentSheet(
                        context,
                        post.id,
                        currentPetId,
                        ref.read(activePetProvider)?.name ?? 'Unknown',
                      );
                    },
                    onShareIconTap: () => _showShareSheet(context, post.id),
                    onPetTap: () {
                      ref.read(profilePetNavigationProvider.notifier).navigateTo(post.pet.id);
                    },
                  );
                },
                childCount: feedState.posts.length,
              ),
            ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context, String postId) {
    final shareLink = 'https://petsphere.app/post/$postId';
    Share.share(
      'Check out this pet on PetSphere!\n$shareLink',
      subject: 'PetSphere',
    );
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

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: bg.withAlpha(40),
                          child: Text(
                            comment.petName[0].toUpperCase(),
                            style: TextStyle(
                                color: bg, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(comment.petName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
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

// ── Category chip filter row ───────────────────────────────────────────────
class _CategoryChipsRow extends StatefulWidget {
  @override
  State<_CategoryChipsRow> createState() => _CategoryChipsRowState();
}

class _CategoryChipsRowState extends State<_CategoryChipsRow> {
  String? _selected; // null = All Stories

  static const _chips = [
    (label: 'All Stories', value: null as String?),
    (label: 'Dogs', value: 'Dog' as String?),
    (label: 'Cats', value: 'Cat' as String?),
    (label: 'Exotic', value: 'Exotic' as String?),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: _chips.map((chip) {
          final isSelected = _selected == chip.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selected = chip.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF506453) : const Color(0xFFE5FDE6),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected
                      ? [BoxShadow(color: const Color(0xFF506453).withAlpha(40), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  chip.label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE8FFE8) : const Color(0xFF4E6251),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
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

