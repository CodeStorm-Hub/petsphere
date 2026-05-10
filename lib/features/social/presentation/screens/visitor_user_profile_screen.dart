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
  final String userId;
  const VisitorUserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<VisitorUserProfileScreen> createState() => _VisitorUserProfileScreenState();
}

class _VisitorUserProfileScreenState extends ConsumerState<VisitorUserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(visitorUserProvider(widget.userId));
    final petsAsync = ref.watch(visitorUserPetsProvider(widget.userId));
    final cs = Theme.of(context).colorScheme;

    return userAsync.when(
      data: (user) {
        if (user == null) return _buildNotFound(context, cs);
        return Scaffold(
          appBar: AppBar(
            title: Text(user.name ?? 'Profile', style: GoogleFonts.playfairDisplay()),
            actions: [
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          body: Column(
            children: [
              _buildHeader(context, user, cs),
              _buildActionButtons(context, user, cs),
              const Divider(),
              TabBar(
                controller: _tabController,
                indicatorColor: cs.primary,
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Pets'),
                  Tab(text: 'Posts'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPetsGrid(context, petsAsync, cs),
                    _buildPostsGrid(context, user, cs),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: cs.primaryContainer,
            backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                ? CachedNetworkImageProvider(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                ? Text(user.initials, style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: cs.primary))
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'Anonymous Pet Parent',
                  style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (user.location != null)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(user.location!, style: GoogleFonts.dmSans(fontSize: 14, color: cs.onSurfaceVariant)),
                    ],
                  ),
                const SizedBox(height: 8),
                if (user.bio != null)
                  Text(user.bio!, style: GoogleFonts.dmSans(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserModel user, ColorScheme cs) {
    final isFollowingAsync = ref.watch(isFollowingUserProvider(user.id));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: isFollowingAsync.when(
              data: (isFollowing) => FilledButton(
                onPressed: () async {
                  final currentUserId = supabase.auth.currentUser?.id;
                  if (currentUserId == null) return;
                  if (isFollowing) {
                    await followRepository.unfollowOwner(currentUserId, user.id);
                  } else {
                    await followRepository.followOwner(currentUserId, user.id);
                  }
                  ref.invalidate(isFollowingUserProvider(user.id));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: isFollowing ? cs.surfaceContainerHigh : cs.primary,
                  foregroundColor: isFollowing ? cs.onSurface : cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isFollowing ? 'Following' : 'Follow'),
              ),
              loading: () => const FilledButton(onPressed: null, child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              error: (e, st) => const FilledButton(onPressed: null, child: Text('Error')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.push('/chat/${user.id}'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsGrid(BuildContext context, AsyncValue<List<PetModel>> petsAsync, ColorScheme cs) {
    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) return const Center(child: Text('No pets yet'));
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return InkWell(
              onTap: () => context.push('/pet/${pet.id}'),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: pet.profileImageUrl.isNotEmpty
                          ? CachedNetworkImage(imageUrl: pet.profileImageUrl, fit: BoxFit.cover, width: double.infinity)
                          : Container(color: cs.primaryContainer, child: const Center(child: Icon(Icons.pets))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pet.name, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                          Text(pet.breed, style: GoogleFonts.dmSans(fontSize: 12, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
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

  Widget _buildPostsGrid(BuildContext context, UserModel user, ColorScheme cs) {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 12, // Placeholder
      itemBuilder: (context, index) => Container(
        color: cs.surfaceContainerLow,
        child: Icon(Icons.image_outlined, color: cs.onSurfaceVariant.withValues(alpha: 0.1)),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context, ColorScheme cs) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('User not found')),
    );
  }
}
