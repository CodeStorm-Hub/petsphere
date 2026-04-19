import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_dating_app/repositories/pet_repository.dart';
import 'package:pet_dating_app/models/pet_model.dart';
import 'package:pet_dating_app/controllers/match_controller.dart';
import 'package:pet_dating_app/controllers/follow_controller.dart';
import 'package:pet_dating_app/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';

// Load pet by ID from Supabase
final _petByIdProvider = FutureProvider.family<PetModel?, String>((ref, petId) {
  return petRepository.fetchPetById(petId);
});

class MatchPetProfileScreen extends ConsumerWidget {
  final String petId;

  const MatchPetProfileScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(_petByIdProvider(petId));

    return petAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error loading pet: $e'))),
      data: (pet) {
        if (pet == null) {
          return const Scaffold(
              body: Center(child: Text('Pet not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(pet.name),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_petByIdProvider(petId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 300,
                  child: pet.profileImageUrl.isNotEmpty
                      ? Image.network(pet.profileImageUrl, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.pets,
                              size: 80, color: Colors.grey),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Age
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${pet.age} yrs',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Breed: ${pet.breed}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      // Follower count
                      const SizedBox(height: 8),
                      _PetFollowerCount(petId: pet.id),

                      // Follow Buttons
                      const SizedBox(height: 16),
                      _FollowButtonsRow(pet: pet),

                      const SizedBox(height: 24),
                      const Text('About',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(pet.bio,
                          style:
                              const TextStyle(fontSize: 16, height: 1.5)),
                      const SizedBox(height: 32),
                      const Text('Medical Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text('Fully Vaccinated'),
                          const Spacer(),
                          if (pet.isPublicOwner)
                            const Chip(label: Text('Owner Info Public')),
                        ],
                      ),
                      const SizedBox(height: 48),
                      if (ref.watch(authProvider).user?.id != pet.userId)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.favorite),
                            label: const Text('Send Match Request'),
                            onPressed: () async {
                              final success = await ref
                                  .read(matchProvider.notifier)
                                  .sendLikeRequest(pet.id);
                              if (!context.mounted) return;
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Breeding request sent for ${pet.name}!')),
                                );
                                context.pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Could not send request.')),
                                );
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Follow Buttons Row — Follow Pet + Follow Owner
// ---------------------------------------------------------------------------
class _FollowButtonsRow extends ConsumerWidget {
  final PetModel pet;

  const _FollowButtonsRow({required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider).user?.id;
    final isOwnPet = currentUserId == pet.userId;

    // Don't show follow buttons for your own pets
    if (isOwnPet || currentUserId == null) return const SizedBox.shrink();

    final isFollowingPet = ref.watch(isFollowingPetProvider(pet.id));
    final isFollowingOwner = ref.watch(isFollowingOwnerProvider(pet.userId));

    return Row(
      children: [
        // Follow Pet button
        Expanded(
          child: isFollowingPet.when(
            loading: () => const _FollowButtonSkeleton(label: 'Follow Pet'),
            error: (_, _) => const SizedBox.shrink(),
            data: (following) => _FollowButton(
              label: following ? 'Following' : 'Follow Pet',
              icon: following ? Icons.pets : Icons.pets_outlined,
              isFollowing: following,
              color: const Color(0xFFFF8A65),
              onPressed: () async {
                await ref
                    .read(followControllerProvider.notifier)
                    .toggleFollowPet(pet.id);
                // Also refresh owner follow state in case it changed
                ref.invalidate(isFollowingOwnerProvider(pet.userId));
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Follow Owner button
        Expanded(
          child: isFollowingOwner.when(
            loading: () =>
                const _FollowButtonSkeleton(label: 'Follow Owner'),
            error: (_, _) => const SizedBox.shrink(),
            data: (following) => _FollowButton(
              label: following ? 'Following Owner' : 'Follow Owner',
              icon: following
                  ? Icons.person_rounded
                  : Icons.person_add_alt_1_outlined,
              isFollowing: following,
              color: const Color(0xFF4FC3F7),
              onPressed: () async {
                await ref
                    .read(followControllerProvider.notifier)
                    .toggleFollowOwner(pet.userId);
                // Refresh pet follow state too (owner follow implies pet follow)
                ref.invalidate(isFollowingPetProvider(pet.id));
                ref.invalidate(petFollowerCountProvider(pet.id));
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Follow Button
// ---------------------------------------------------------------------------
class _FollowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isFollowing;
  final Color color;
  final VoidCallback onPressed;

  const _FollowButton({
    required this.label,
    required this.icon,
    required this.isFollowing,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: isFollowing
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18, color: color),
              label: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Follow Button Skeleton (loading state)
// ---------------------------------------------------------------------------
class _FollowButtonSkeleton extends StatelessWidget {
  final String label;

  const _FollowButtonSkeleton({required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pet Follower Count
// ---------------------------------------------------------------------------
class _PetFollowerCount extends ConsumerWidget {
  final String petId;

  const _PetFollowerCount({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(petFollowerCountProvider(petId));

    return countAsync.when(
      loading: () => Text(
        'Loading followers...',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (count) => Row(
        children: [
          Icon(Icons.people_outline, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            '$count ${count == 1 ? 'follower' : 'followers'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
