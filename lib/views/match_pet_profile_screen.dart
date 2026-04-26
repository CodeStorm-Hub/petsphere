import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../models/user_model.dart';
import '../repositories/pet_repository.dart';
import '../controllers/auth_controller.dart';
import '../controllers/feed_controller.dart';
import '../controllers/follow_controller.dart';
import '../controllers/match_controller.dart';
import 'package:go_router/go_router.dart';

typedef ProfileArgs = ({String? petId, String? userId});

final _publicProfileDataProvider = FutureProvider.family<Map<String, dynamic>, ProfileArgs>((ref, args) async {
  final petId = args.petId;
  final userIdArg = args.userId;

  String targetUserId;
  PetModel? initialPet;

  if (petId != null) {
    initialPet = await petRepository.fetchPetById(petId);
    if (initialPet == null) throw Exception('Pet not found');
    targetUserId = initialPet.userId;
  } else if (userIdArg != null) {
    targetUserId = userIdArg;
  } else {
    throw Exception('Must provide petId or userId');
  }

  final user = await ref.read(publicUserProvider(targetUserId).future);
  final allPets = await petRepository.fetchMyPets(targetUserId);
  
  return {
    'user': user,
    'pets': allPets,
    'initialPet': initialPet,
  };
});

class MatchPetProfileScreen extends ConsumerStatefulWidget {
  final String? petId;
  final String? userId;
  const MatchPetProfileScreen({super.key, this.petId, this.userId});

  @override
  ConsumerState<MatchPetProfileScreen> createState() => _MatchPetProfileScreenState();
}

class _MatchPetProfileScreenState extends ConsumerState<MatchPetProfileScreen> {
  String? selectedId;
  String? _postCategory;

  @override
  Widget build(BuildContext context) {
    final args = (petId: widget.petId, userId: widget.userId);
    final asyncData = ref.watch(_publicProfileDataProvider(args));

    return asyncData.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (data) {
        final UserModel user = data['user'];
        final List<PetModel> pets = data['pets'];
        final PetModel? initialPet = data['initialPet'];

        selectedId ??= (initialPet?.id ?? 'owner');
        final isOwnerView = selectedId == 'owner';

        PetModel? selectedPet;
        if (!isOwnerView) {
          selectedPet = pets.firstWhere((p) => p.id == selectedId, orElse: () => pets.first);
        }

        final feedState = ref.watch(feedProvider);
        final allPosts = isOwnerView
            ? feedState.posts.where((post) => post.pet.userId == user.id).toList()
            : feedState.posts.where((post) => post.pet.id == selectedPet?.id).toList();

        final displayedPosts = (_postCategory == null || isOwnerView)
            ? allPosts
            : allPosts.where((p) => p.caption.toLowerCase().contains(_postCategory!.toLowerCase())).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(isOwnerView ? user.name ?? 'Pet Lover' : (selectedPet?.name ?? 'Pet')),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_publicProfileDataProvider(args));
              await ref.read(feedProvider.notifier).refresh();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: () {
                              final coverUrl = isOwnerView ? (user.profileImageUrl ?? '') : (selectedPet?.profileImageUrl ?? '');
                              return coverUrl.isNotEmpty
                                  ? Image.network(coverUrl, fit: BoxFit.cover)
                                  : Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFFFFAD93), Color(0xFFFFE087)],
                                        ),
                                      ),
                                    );
                            }(),
                          ),
                          Positioned(
                            bottom: -44,
                            left: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFFEF8F3), width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: const Color(0xFFE5FDE6),
                                backgroundImage: () {
                                  final url = isOwnerView ? user.profileImageUrl : selectedPet?.profileImageUrl;
                                  return (url != null && url.isNotEmpty) ? NetworkImage(url) : null;
                                }(),
                                child: () {
                                  final url = isOwnerView ? user.profileImageUrl : selectedPet?.profileImageUrl;
                                  if (url != null && url.isNotEmpty) return null;
                                  return Icon(isOwnerView ? Icons.person : Icons.pets, size: 40, color: const Color(0xFF99472C));
                                }(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 52),

                      // Carousel
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => selectedId = 'owner'),
                              child: _AvatarRing(
                                isSelected: isOwnerView,
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: (user.profileImageUrl?.isNotEmpty ?? false) ? NetworkImage(user.profileImageUrl!) : null,
                                  child: (user.profileImageUrl?.isEmpty ?? true) ? const Icon(Icons.person) : null,
                                ),
                              ),
                            ),
                            for (final pet in pets)
                              GestureDetector(
                                onTap: () => setState(() => selectedId = pet.id),
                                child: _AvatarRing(
                                  isSelected: pet.id == selectedId,
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: pet.profileImageUrl.isNotEmpty ? NetworkImage(pet.profileImageUrl) : null,
                                    child: pet.profileImageUrl.isEmpty ? const Icon(Icons.pets) : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOwnerView ? (user.name ?? '') : (selectedPet?.name ?? ''),
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            if (!isOwnerView && selectedPet != null)
                              Text('${selectedPet.breed} · ${selectedPet.animalType} · ${selectedPet.age} yrs', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(
                              isOwnerView ? (user.bio ?? 'No bio yet') : (selectedPet?.bio ?? 'No bio yet'),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            
                            // Stats
                            Row(
                              children: [
                                _StatColumn(label: 'Posts', value: '${displayedPosts.length}'),
                                const SizedBox(width: 28),
                                if (isOwnerView) ...[
                                  ref.watch(ownerFollowerCountProvider(user.id)).when(
                                    data: (c) => _StatColumn(label: 'Followers', value: '$c'),
                                    loading: () => const _StatColumn(label: 'Followers', value: '···'),
                                    error: (_, __) => const _StatColumn(label: 'Followers', value: '0'),
                                  ),
                                ] else if (selectedPet != null) ...[
                                  ref.watch(petFollowerCountProvider(selectedPet.id)).when(
                                    data: (c) => _StatColumn(label: 'Followers', value: '$c'),
                                    loading: () => const _StatColumn(label: 'Followers', value: '···'),
                                    error: (_, __) => const _StatColumn(label: 'Followers', value: '0'),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Follow/Match Buttons
                            if (!isOwnerView && selectedPet != null) ...[
                              _FollowButtonsRow(pet: selectedPet),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.favorite),
                                  label: const Text('Send Match Request'),
                                  onPressed: () async {
                                    final success = await ref.read(matchProvider.notifier).sendLikeRequest(selectedPet!.id);
                                    if (mounted && success) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent to ${selectedPet.name}!')));
                                    }
                                  },
                                ),
                              ),
                            ] else if (isOwnerView) ...[
                              SizedBox(
                                width: double.infinity,
                                child: _OwnerFollowButton(userId: user.id),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Posts Grid
                if (displayedPosts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No posts yet', style: TextStyle(color: Colors.grey))),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = displayedPosts[index];
                          return GestureDetector(
                            onTap: () => context.push('/post/${post.id}'),
                            child: post.mediaUrl.isNotEmpty
                                ? Image.network(post.mediaUrl, fit: BoxFit.cover)
                                : Container(color: Colors.grey.shade200),
                          );
                        },
                        childCount: displayedPosts.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvatarRing extends StatelessWidget {
  final bool isSelected;
  final Widget child;
  const _AvatarRing({required this.isSelected, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFFFAD04B) : Colors.transparent,
          width: 2,
        ),
      ),
      child: child,
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _FollowButtonsRow extends ConsumerWidget {
  final PetModel pet;
  const _FollowButtonsRow({required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followsAsync = ref.watch(isFollowingPetProvider(pet.id));
    final follows = followsAsync.value ?? false;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: follows ? Colors.grey.shade200 : Theme.of(context).colorScheme.primary,
              foregroundColor: follows ? Colors.black : Colors.white,
            ),
            onPressed: () {
              ref.read(followControllerProvider.notifier).toggleFollowPet(pet.id);
            },
            child: Text(follows ? 'Unfollow' : 'Follow'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // TODO: Implement messaging
            },
            child: const Text('Message'),
          ),
        ),
      ],
    );
  }
}

class _OwnerFollowButton extends ConsumerWidget {
  final String userId;
  const _OwnerFollowButton({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followsAsync = ref.watch(isFollowingOwnerProvider(userId));
    final follows = followsAsync.value ?? false;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: follows ? Colors.grey.shade200 : Theme.of(context).colorScheme.primary,
        foregroundColor: follows ? Colors.black : Colors.white,
      ),
      onPressed: () {
        ref.read(followControllerProvider.notifier).toggleFollowOwner(userId);
      },
      child: Text(follows ? 'Unfollow Owner' : 'Follow Owner'),
    );
  }
}
