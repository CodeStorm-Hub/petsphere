import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/feed_controller.dart';
import '../models/pet_model.dart';


class PetProfileScreen extends ConsumerStatefulWidget {
  const PetProfileScreen({super.key});

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen> {
  // We keep track of which context the user is looking at.
  // Initially null, which we can map to the "First Pet" or "Owner"
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);
    final authState = ref.watch(authProvider);
    final feedState = ref.watch(feedProvider);
    final theme = Theme.of(context);

    if (petState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final myOwnedPets = petState.myPets;
    final userName = authState.user?.name ?? 'Pet Owner';

    // Auto-select first pet if none selected
    if (selectedId == null && myOwnedPets.isNotEmpty) {
      selectedId = myOwnedPets.first.id;
    }

    // Determine active context
    final isOwnerView = selectedId == 'owner_all';
    PetModel? selectedPet;

    if (!isOwnerView && myOwnedPets.isNotEmpty) {
       selectedPet = myOwnedPets.firstWhere(
         (p) => p.id == selectedId,
         orElse: () => myOwnedPets.first
       );
    }

    // Compute specific posts to display
    final displayedPosts = isOwnerView
      ? feedState.posts.where((post) => myOwnedPets.any((p) => p.id == post.pet.id)).toList()
      : feedState.posts.where((post) => post.pet.id == selectedId).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: theme.colorScheme.onSurface,
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        elevation: 8,
        child: const Icon(Icons.edit),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Header with Cover Photo and Profile Picture
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Cover Photo
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?q=80&w=1000&auto=format&fit=crop', // Beautiful park placeholder
                    fit: BoxFit.cover,
                  ),
                ),
                // Profile Avatar Overlapping
                Positioned(
                  bottom: -50,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.surface, width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: isOwnerView
                          ? const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop')
                          : selectedPet != null ? NetworkImage(selectedPet.profileImageUrl) : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // Spacing for overlapping avatar

            // Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    isOwnerView ? userName : (selectedPet?.name ?? 'Unknown'),
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (!isOwnerView && selectedPet != null)
                    Text(
                      '${selectedPet.breed} • Brooklyn, NY', // Mock Location
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatColumn(label: 'Posts', value: '${displayedPosts.length}', theme: theme),
                      Container(height: 40, width: 1, color: theme.colorScheme.surfaceContainerHighest, margin: const EdgeInsets.symmetric(horizontal: 24)),
                      _StatColumn(label: 'Followers', value: '1.2k', theme: theme),
                      Container(height: 40, width: 1, color: theme.colorScheme.surfaceContainerHighest, margin: const EdgeInsets.symmetric(horizontal: 24)),
                      _StatColumn(label: 'Following', value: '342', theme: theme),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bio
                  Text(
                    isOwnerView ? 'Human Owner of ${myOwnedPets.length} beautiful pets across the network!' : (selectedPet?.bio ?? ''),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Pet Carousel (to switch contexts)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: myOwnedPets.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedId = 'owner_all'),
                      child: _OwnerCarouselAvatar(name: 'All', isSelected: isOwnerView, theme: theme),
                    );
                  }
                  if (index == myOwnedPets.length + 1) {
                    return _AddPetAvatar(theme: theme);
                  }
                  final pet = myOwnedPets[index - 1];
                  final isSelected = pet.id == selectedId;
                  return GestureDetector(
                    onTap: () => setState(() => selectedId = pet.id),
                    child: _PetCarouselAvatar(pet: pet, isSelected: isSelected, theme: theme),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Media Grid
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, -4))
                ]
              ),
              padding: const EdgeInsets.all(16),
              child: displayedPosts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Center(
                        child: Text('No posts yet.', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: displayedPosts.length,
                      itemBuilder: (context, index) {
                        final post = displayedPosts[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                post.mediaUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: theme.colorScheme.surfaceContainerHighest),
                              ),
                              if (isOwnerView)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: NetworkImage(post.pet.profileImageUrl),
                                  ),
                                )
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class _OwnerCarouselAvatar extends StatelessWidget {
  final String name;
  final bool isSelected;
  final ThemeData theme;
  
  const _OwnerCarouselAvatar({required this.name, required this.isSelected, required this.theme});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop'),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: theme.textTheme.labelMedium?.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}


class _PetCarouselAvatar extends StatelessWidget {
  final PetModel pet;
  final bool isSelected;
  final ThemeData theme;
  
  const _PetCarouselAvatar({required this.pet, required this.isSelected, required this.theme});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(pet.profileImageUrl),
            ),
          ),
          const SizedBox(height: 4),
          Text(pet.name, style: theme.textTheme.labelMedium?.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _AddPetAvatar extends StatelessWidget {
  final ThemeData theme;
  const _AddPetAvatar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(Icons.add, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 4),
          Text('Add Pet', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  
  const _StatColumn({required this.label, required this.value, required this.theme});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
