import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/pet/data/pet_repository.dart';
import 'package:petfolio/features/social/data/follow_repository.dart';
import 'package:petfolio/features/social/presentation/controllers/feed_controller.dart';
import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';

final visitorPetProvider =
    FutureProvider.family<PetModel?, String>((ref, petId) async {
      final repo = ref.watch(petRepositoryProvider);
      return repo.fetchPetById(petId);
    });

final isFollowingPetProvider =
    FutureProvider.family<bool, String>((ref, petId) async {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;
      return followRepository.isFollowingPet(userId, petId);
    });

class VisitorPetProfileScreen extends ConsumerStatefulWidget {
  final String petId;
  const VisitorPetProfileScreen({super.key, required this.petId});

  @override
  ConsumerState<VisitorPetProfileScreen> createState() =>
      _VisitorPetProfileScreenState();
}

class _VisitorPetProfileScreenState extends ConsumerState<VisitorPetProfileScreen>
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
    if (_scrollController.offset > 240 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 240 && _showTitle) {
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
    final petAsync = ref.watch(visitorPetProvider(widget.petId));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return petAsync.when(
      data: (pet) {
        if (pet == null) return _buildNotFound(context, cs);
        return Scaffold(
          body: PetFolioGradientBackground(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(context, pet, cs),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(context, pet, cs),
                      _buildActionButtons(context, pet, cs),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    child: Container(
                      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: cs.primary,
                        labelColor: cs.primary,
                        unselectedLabelColor: cs.onSurfaceVariant,
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(icon: Icon(Icons.grid_on_rounded), text: 'Photos'),
                          Tab(icon: Icon(Icons.emoji_events_outlined), text: 'Awards'),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPhotosGrid(pet, cs),
                      _buildAchievementsTab(cs),
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

  Widget _buildSliverAppBar(BuildContext context, PetModel pet, ColorScheme cs) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(80),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          pet.name,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(80),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () async {
              await SharePlus.instance.share(
                ShareParams(
                  text: 'Check out ${pet.name} on PetFolio! ${pet.breed} looking for friends.',
                ),
              );
            },
            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(80),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => _showMoreOptions(context, pet),
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (pet.profileImageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: pet.profileImageUrl,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: cs.primaryContainer,
                child: Icon(Icons.pets, size: 80, color: cs.primary),
              ),
            // Premium Gradient Overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black45,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black87,
                  ],
                  stops: [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, PetModel pet, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pet.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        if (pet.isVerified) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.verified, size: 24, color: cs.primary),
                        ],
                      ],
                    ),
                    Text(
                      '${pet.animalType} • ${pet.breed.isEmpty ? 'Unknown Breed' : pet.breed}',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatItem(context, '2.4k', 'Fans', cs),
            ],
          ),
          const SizedBox(height: 16),
          if (pet.bio.isNotEmpty)
            Text(
              pet.bio,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                height: 1.5,
                color: cs.onSurface,
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoChip(
                context,
                Icons.cake_outlined,
                '${pet.age} years old',
                cs,
              ),
              const SizedBox(width: 8),
              if (pet.isVaccinated)
                _buildInfoChip(
                  context,
                  Icons.health_and_safety_outlined,
                  'Vaccinated',
                  cs,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    ColorScheme cs,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    ColorScheme cs,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withAlpha(120),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outline.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PetModel pet,
    ColorScheme cs,
  ) {
    final isFollowingAsync = ref.watch(isFollowingPetProvider(pet.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: isFollowingAsync.when(
              data:
                  (isFollowing) => PillButton(
                    key: const ValueKey('visitor_pet_profile_follow_button'),
                    outlined: isFollowing,
                    onPressed: () async {
                      final userId = supabase.auth.currentUser?.id;
                      if (userId == null) {
                        await context.push('/login');
                        return;
                      }
                      if (isFollowing) {
                        await followRepository.unfollowPet(userId, pet.id);
                      } else {
                        await followRepository.followPet(userId, pet.id);
                      }
                      ref.invalidate(isFollowingPetProvider(pet.id));
                    },
                    icon: isFollowing ? Icons.check : Icons.add,
                    child: Text(isFollowing ? 'Following' : 'Follow'),
                  ),
              loading:
                  () => const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              error: (e, st) => const Text('Error'),
            ),
          ),
          const SizedBox(width: 12),
          PillButton(
            key: const ValueKey('visitor_pet_profile_message_button'),
            onPressed: () => context.push('/chat/${pet.userId}'),
            icon: Icons.mail_outline_rounded,
            outlined: true,
            child: const Text('Message'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid(PetModel pet, ColorScheme cs) {
    final postsAsync = ref.watch(petPostsProvider(pet.id));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 48, color: cs.outline),
                const SizedBox(height: 12),
                Text(
                  'No photos shared yet',
                  style: GoogleFonts.dmSans(color: cs.onSurfaceVariant),
                ),
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
              child: Hero(
                tag: 'post_${post.id}',
                child: Container(
                  color: cs.surfaceContainerLow,
                  child: CachedNetworkImage(
                    imageUrl: post.mediaUrl,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(color: cs.surfaceContainer),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading:
          () => const Center(
            child: CircularProgressIndicator(),
          ),
      error: (e, st) => Center(child: Text('Error loading photos: $e')),
    );
  }

  Widget _buildAchievementsTab(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 48, color: cs.outline),
          const SizedBox(height: 12),
          Text(
            'No awards yet',
            style: GoogleFonts.dmSans(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound(BuildContext context, ColorScheme cs) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Pet not found',
          style: GoogleFonts.playfairDisplay(fontSize: 24),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, PetModel pet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
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
                  title: const Text('Report Pet'),
                  onTap: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report submitted. Thank you.')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block_flipped),
                  title: const Text('Block Owner'),
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
  final Widget child;
  _SliverAppBarDelegate({required this.child});

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
