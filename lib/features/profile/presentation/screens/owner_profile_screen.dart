import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/social/presentation/controllers/follow_controller.dart';
import 'package:petfolio/features/social/presentation/controllers/feed_controller.dart';
import 'package:petfolio/features/profile/presentation/widgets/active_pet_switcher_modal.dart';
import 'package:petfolio/core/widgets/petfolio_empty_state.dart';

class OwnerProfileScreen extends ConsumerStatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  ConsumerState<OwnerProfileScreen> createState() =>
      _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends ConsumerState<OwnerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final petState = ref.watch(petProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _OwnerSliverAppBar(user: user),
              SliverToBoxAdapter(
                child: _OwnerInfoSection(user: user),
              ),
              SliverToBoxAdapter(
                child: _StatsRow(userId: user.id),
              ),
              SliverToBoxAdapter(
                child: _ActionButtons(user: user),
              ),
              SliverToBoxAdapter(
                child: _MyPetsSection(
                  pets: petState.myPets,
                  activePet: petState.activePet,
                  isLoading: petState.isLoading,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: cs.primary,
                    labelColor: cs.primary,
                    unselectedLabelColor: cs.onSurfaceVariant,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on_rounded), text: 'Posts'),
                      Tab(
                        icon: Icon(Icons.emoji_events_outlined),
                        text: 'Achievements',
                      ),
                      Tab(
                        icon: Icon(Icons.timeline_outlined),
                        text: 'Activity',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _PostsTab(userId: user.id),
                _AchievementsTab(cs: cs),
                _ActivityTab(cs: cs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sliver App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _OwnerSliverAppBar extends StatelessWidget {
  const _OwnerSliverAppBar({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: cs.surface,
      title: Text(
        'My Profile',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      actions: [
        IconButton(
          key: const ValueKey('owner_profile_share_button'),
          onPressed: () async {
            await SharePlus.instance.share(
              ShareParams(
                text:
                    'Check out my profile on PetFolio! Join me and my pets.',
              ),
            );
          },
          icon: const Icon(Icons.share_outlined),
        ),
        IconButton(
          key: const ValueKey('owner_profile_settings_button'),
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Owner Info Section — avatar, name, bio, location
// ─────────────────────────────────────────────────────────────────────────────
class _OwnerInfoSection extends StatelessWidget {
  const _OwnerInfoSection({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = (user.name as String?) ?? 'Pet Parent';
    final bio = (user.bio as String?) ?? '';
    final location = (user.location as String?) ?? '';
    final imageUrl = (user.profileImageUrl as String?) ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.primary, width: 3),
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: cs.primaryContainer,
              backgroundImage:
                  imageUrl.isNotEmpty ? CachedNetworkImageProvider(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? Text(
                      user.initials as String,
                      style: tt.headlineMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(location,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(bio, style: tt.bodyMedium, maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row — Followers | Following | Posts
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final followers = ref.watch(ownerFollowerCountProvider(userId));
    final following = ref.watch(followingCountProvider(userId));
    final posts = ref.watch(userPostsProvider(userId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatCell(
              value: followers.when(
                data: (v) => _formatCount(v),
                loading: () => '…',
                error: (_, _) => '0',
              ),
              label: 'Followers',
              onTap: () => context.push('/user/$userId/followers'),
            ),
            Container(width: 1, height: 32, color: cs.outlineVariant),
            _StatCell(
              value: following.when(
                data: (v) => _formatCount(v),
                loading: () => '…',
                error: (_, _) => '0',
              ),
              label: 'Following',
              onTap: () => context.push('/user/$userId/following'),
            ),
            Container(width: 1, height: 32, color: cs.outlineVariant),
            _StatCell(
              value: posts.when(
                data: (v) => _formatCount(v.length),
                loading: () => '…',
                error: (_, _) => '0',
              ),
              label: 'Posts',
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label, this.onTap});
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            Text(value,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons — Edit Profile | Switch Pet
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              key: const ValueKey('owner_edit_profile_button'),
              onPressed: () => context.push(AppRoutes.settings),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            key: const ValueKey('owner_switch_pet_button'),
            onPressed: () => ActivePetSwitcherModal.show(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: cs.outline),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Switch Pet'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Pets Section — horizontal card list
// ─────────────────────────────────────────────────────────────────────────────
class _MyPetsSection extends ConsumerWidget {
  const _MyPetsSection({
    required this.pets,
    required this.activePet,
    required this.isLoading,
  });
  final List<PetModel> pets;
  final PetModel? activePet;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Pets',
                    style:
                        tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => context.push(AppRoutes.managePets),
                  child: const Text('Manage'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pets.length + 1, // +1 for "Add Pet"
                    itemBuilder: (context, index) {
                      if (index == pets.length) {
                        return _AddPetCard(cs: cs);
                      }
                      final pet = pets[index];
                      final isActive = activePet?.id == pet.id;
                      return _PetMiniCard(
                        pet: pet,
                        isActive: isActive,
                        onTap: () =>
                            context.push(AppRoutes.petProfileById(pet.id)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PetMiniCard extends StatelessWidget {
  const _PetMiniCard({
    required this.pet,
    required this.isActive,
    required this.onTap,
  });
  final PetModel pet;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? cs.primaryContainer.withAlpha(80)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: cs.primary, width: 2)
              : Border.all(color: cs.outlineVariant.withAlpha(80)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primaryContainer,
              backgroundImage: pet.profileImageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(pet.profileImageUrl)
                  : null,
              child: pet.profileImageUrl.isEmpty
                  ? Icon(Icons.pets, color: cs.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              pet.name,
              style: tt.bodySmall?.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('Active',
                    style: tt.labelSmall?.copyWith(color: cs.primary)),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddPetCard extends StatelessWidget {
  const _AddPetCard({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.addPet),
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.primary.withAlpha(100),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withAlpha(30),
              ),
              child: Icon(Icons.add_rounded, color: cs.primary, size: 28),
            ),
            const SizedBox(height: 8),
            Text('Add Pet',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Posts Tab
// ─────────────────────────────────────────────────────────────────────────────
class _PostsTab extends ConsumerWidget {
  const _PostsTab({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));
    final cs = Theme.of(context).colorScheme;

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => PetfolioEmptyState(
        icon: Icons.error_outline,
        title: 'Unable to Load Posts',
        message: e.toString(),
        buttonText: 'Retry',
        onButtonPressed: () => ref.invalidate(userPostsProvider(userId)),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return PetfolioEmptyState(
            icon: Icons.photo_library_outlined,
            title: 'No Posts Yet',
            message: 'Share your first pet moment with the community!',
            buttonText: 'Create your first post',
            onButtonPressed: () => context.push(AppRoutes.createPost),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return GestureDetector(
              onTap: () => context.push(AppRoutes.postById(post.id)),
              child: post.mediaUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: post.mediaUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: cs.surfaceContainerLow,
                      child: Center(
                        child: Icon(Icons.text_snippet_outlined,
                            color: cs.onSurfaceVariant),
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Achievements Tab (placeholder)
// ─────────────────────────────────────────────────────────────────────────────
class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PetfolioEmptyState(
      icon: Icons.emoji_events_outlined,
      title: 'No Achievements',
      message: 'Complete pet care goals to earn badges and achievements!',
      buttonText: 'View Care Badges',
      onButtonPressed: () => context.push(AppRoutes.achievements),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity Tab (placeholder)
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return const PetfolioEmptyState(
      icon: Icons.timeline_outlined,
      title: 'No Activity',
      message: 'Your recent pet activities and updates will appear here.',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab bar delegate
// ─────────────────────────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}
