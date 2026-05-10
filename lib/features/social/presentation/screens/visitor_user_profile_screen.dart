import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:petfolio/features/auth/data/models/user_model.dart';
import 'package:petfolio/features/auth/data/auth_repository.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/pet/data/pet_repository.dart';
import 'package:petfolio/features/social/data/follow_repository.dart';
import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import 'package:petfolio/features/social/data/models/post_model.dart';
import 'package:petfolio/features/social/presentation/controllers/feed_controller.dart';
import 'package:share_plus/share_plus.dart';

final visitorUserProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  return authRepository.fetchPublicProfile(userId);
});

final visitorUserPetsProvider = FutureProvider.family<List<PetModel>, String>((ref, userId) async {
  return ref.watch(petRepositoryProvider).fetchMyPets(userId);
});

final isFollowingUserProvider = FutureProvider.family<bool, String>((ref, ownerId) async {
  final currentUserId = supabase.auth.currentUser?.id;
  if (currentUserId == null) return false;
  return followRepository.isFollowingOwner(currentUserId, ownerId);
});

class VisitorUserProfileScreen extends ConsumerStatefulWidget {
  const VisitorUserProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<VisitorUserProfileScreen> createState() =>
      _VisitorUserProfileScreenState();
}

class _VisitorUserProfileScreenState extends ConsumerState<VisitorUserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 120 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 120 && _showTitle) {
      setState(() => _showTitle = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(visitorUserProvider(widget.userId));
    final petsAsync = ref.watch(visitorUserPetsProvider(widget.userId));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return userAsync.when(
      data: (user) {
        if (user == null) return _buildNotFound(context, cs);
        return Scaffold(
          body: PetFolioGradientBackground(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(context, user, cs),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, user, cs),
                      _buildActionButtons(context, user, cs),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    child: Container(
                      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: cs.primary,
                        labelColor: cs.primary,
                        unselectedLabelColor: cs.onSurfaceVariant,
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Pets'),
                          Tab(text: 'Posts'),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPetsGrid(context, petsAsync, cs),
                      _buildPostsGrid(context, widget.userId, cs),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading:
          () => const Scaffold(
            body: PetFolioGradientBackground(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (e, s) => Scaffold(
            body: PetFolioGradientBackground(
              child: Center(child: Text('Error: $e')),
            ),
          ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UserModel user, ColorScheme cs) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          user.name ?? 'Profile',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () async {
            await SharePlus.instance.share(
              ShareParams(
                text: 'Check out ${user.name}\'s profile on PetFolio!',
                subject: 'PetFolio Profile',
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Hero(
            tag: 'user_avatar_${user.id}',
            child: CircleAvatar(
              radius: 44,
              backgroundColor: cs.primaryContainer,
              backgroundImage: user.profileImageUrl != null &&
                      user.profileImageUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                  ? Text(
                      user.initials,
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'Anonymous Pet Parent',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.location!,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                if (user.bio != null)
                  Text(
                    user.bio!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      height: 1.4,
                      color: cs.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    UserModel user,
    ColorScheme cs,
  ) {
    final isFollowingAsync = ref.watch(isFollowingUserProvider(user.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: isFollowingAsync.when(
              data:
                  (isFollowing) => PillButton(
                    onPressed: () async {
                      final currentUserId = supabase.auth.currentUser?.id;
                      if (currentUserId == null) return;
                      if (isFollowing) {
                        await followRepository.unfollowOwner(
                          currentUserId,
                          user.id,
                        );
                      } else {
                        await followRepository.followOwner(currentUserId, user.id);
                      }
                      ref.invalidate(isFollowingUserProvider(user.id));
                    },
                    outlined: isFollowing,
                    child: Text(isFollowing ? 'Following' : 'Follow'),
                  ),
              loading:
                  () => const PillButton(
                    onPressed: null,
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              error: (e, st) => const PillButton(onPressed: null, child: Text('Error')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PillButton(
              onPressed: () => context.push('/chat/${user.id}'),
              outlined: true,
              child: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsGrid(
    BuildContext context,
    AsyncValue<List<PetModel>> petsAsync,
    ColorScheme cs,
  ) {
    return petsAsync.when(
      data: (List<PetModel> pets) {
        if (pets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets_outlined, size: 48, color: cs.outline),
                const SizedBox(height: 12),
                Text('No pets yet', style: GoogleFonts.dmSans(color: cs.onSurfaceVariant)),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return GestureDetector(
              onTap: () => context.push('/pet/${pet.id}'),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: pet.profileImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: pet.profileImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: cs.primaryContainer.withValues(alpha: 0.3),
                              child: Center(
                                child: Icon(Icons.pets, color: cs.primary, size: 40),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            pet.breed,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPostsGrid(BuildContext context, String userId, ColorScheme cs) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      data: (List<PostModel> posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 48, color: cs.outline),
                const SizedBox(height: 12),
                Text('No posts yet', style: GoogleFonts.dmSans(color: cs.onSurfaceVariant)),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(1),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return GestureDetector(
              onTap: () => context.push('/post/${post.id}'),
              child: CachedNetworkImage(
                imageUrl: post.mediaUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: cs.surfaceContainer),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildNotFound(BuildContext context, ColorScheme cs) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'User not found',
          style: GoogleFonts.playfairDisplay(fontSize: 24),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.report_gmailerrorred_rounded),
              title: const Text('Report User'),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_flipped),
              title: const Text('Block User'),
              onTap: () => context.pop(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
