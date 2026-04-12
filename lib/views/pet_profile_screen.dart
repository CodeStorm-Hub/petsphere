import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/pet_model.dart';

class PetProfileScreen extends ConsumerStatefulWidget {
  const PetProfileScreen({super.key});

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen> {
  // 'owner' represents the global master view. Null means uninitialized.
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Pet Lover';

    // Real pets from petProvider
    final petState = ref.watch(petProvider);
    final myOwnedPets = petState.myPets;

    // Default to 'owner' view
    selectedId ??= 'owner';

    final isOwnerView = selectedId == 'owner';

    PetModel? selectedPet;
    if (!isOwnerView && myOwnedPets.isNotEmpty) {
      selectedPet = myOwnedPets.firstWhere(
        (p) => p.id == selectedId,
        orElse: () => myOwnedPets.first,
      );
    }

    // Post grid from real FeedState
    final feedState = ref.watch(feedProvider);
    final myUserId = authState.user?.id ?? '';
    final displayedPosts = isOwnerView
        ? feedState.posts.where((post) => post.pet.userId == myUserId).toList()
        : feedState.posts
            .where((post) => post.pet.id == selectedPet?.id)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnerView ? 'My Account' : selectedPet!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Padding(
                   padding: EdgeInsets.only(left: 16.0, top: 12.0),
                   child: Text(
                     'Manage Context', 
                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                 ),
                 
                 // 2. Horizontal Pet Carousel
                 SizedBox(
                   height: 115,
                   child: ListView.builder(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     scrollDirection: Axis.horizontal,
                     itemCount: myOwnedPets.length + 2, // Owner, Pets, Add Row
                     itemBuilder: (context, index) {
                       
                       // A. The First item is always the Global Owner Avatar
                       if (index == 0) {
                         return GestureDetector(
                           onTap: () {
                             setState(() {
                               selectedId = 'owner';
                             });
                           },
                           child: _OwnerCarouselAvatar(
                             name: 'All', 
                             isSelected: isOwnerView,
                           ),
                         );
                       }
                       
                       // B. The Last item is the Add Button
                       if (index == myOwnedPets.length + 1) {
                         return GestureDetector(
                           onTap: () => context.push('/add_pet'),
                           child: const _AddPetAvatar(),
                         );
                       }
                       
                       // C. Middle items are the Pets
                       final petIndex = index - 1;
                       final pet = myOwnedPets[petIndex];
                       final isSelected = pet.id == selectedId;
                       
                       return GestureDetector(
                         onTap: () {
                            setState(() {
                               selectedId = pet.id;
                            });
                         },
                         child: _PetCarouselAvatar(pet: pet, isSelected: isSelected),
                       );
                     },
                   ),
                 ),
                 
                 const Divider(),
                 
                 // 3. Active Context Summary
                 Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Container(
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               border: Border.all(color: Colors.grey.shade300, width: 1),
                             ),
                             child: CircleAvatar(
                               radius: 40,
                               backgroundColor: Colors.white,
                               backgroundImage: isOwnerView 
                                 ? const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop') // Human avatar mock
                                 : NetworkImage(selectedPet!.profileImageUrl),
                             ),
                           ),
                           Expanded(
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                               children: [
                                 _StatColumn(label: 'Posts', value: '${displayedPosts.length}'), 
                                 _StatColumn(label: 'Followers', value: isOwnerView ? '503' : '128'),
                                 _StatColumn(label: 'Following', value: isOwnerView ? '312' : '150'),
                               ],
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 12),
                       
                       // Render dynamic context detail cleanly
                       Text(
                         isOwnerView ? userName : selectedPet!.name, 
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                       ),
                       if (!isOwnerView)
                         Text(selectedPet!.breed, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                       
                       const SizedBox(height: 6),
                       Text(isOwnerView ? 'Human Owner of ${myOwnedPets.length} beautiful pets across the network!' : selectedPet!.bio),

                       // Pet detail chips for non-owner view
                       if (!isOwnerView) ...[
                         const SizedBox(height: 12),
                         Wrap(
                           spacing: 8,
                           runSpacing: 8,
                           children: [
                             _InfoChip(
                               icon: Icons.pets,
                               label: selectedPet!.animalType,
                               color: const Color(0xFFFF8A65),
                             ),
                             _InfoChip(
                               icon: Icons.cake_outlined,
                               label: '${selectedPet!.age} ${selectedPet!.age == 1 ? 'year' : 'years'} old',
                               color: const Color(0xFF4FC3F7),
                             ),
                             if (selectedPet!.isPublicOwner)
                               _InfoChip(
                                 icon: Icons.visibility,
                                 label: 'Public Owner',
                                 color: const Color(0xFF81C784),
                               ),
                           ],
                         ),
                       ],

                       const SizedBox(height: 16),
                       
                       Row(
                         children: [
                           Expanded(
                             child: OutlinedButton(
                               onPressed: () {
                                 if (!isOwnerView) {
                                   _showEditPetSheet(context, selectedPet!);
                                 }
                               },
                               child: Text(isOwnerView ? 'Edit Account' : 'Edit Profile'),
                             ),
                           ),
                           const SizedBox(width: 8),
                           Expanded(
                             child: OutlinedButton(
                               onPressed: () {},
                               child: Text(isOwnerView ? 'Share Account' : 'Share Profile'),
                             ),
                           ),
                         ],
                       )
                     ],
                   ),
                 ),
               ],
             ),
          ),
          
          // Empty state with add pet CTA 
          if (myOwnedPets.isEmpty && isOwnerView)
            SliverToBoxAdapter(
              child: _EmptyPetsCta(
                onAddPet: () => context.push('/add_pet'),
              ),
            )
          else if (displayedPosts.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No posts yet!', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        isOwnerView ? 'Create a post to see it here.' : 'Create a post as ${selectedPet?.name ?? 'this pet'}.',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = displayedPosts[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        post.mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => Container(color: Colors.grey.shade200),
                      ),
                      // If Owner view, optionally overlay entirely small author icon so human knows whose picture it is
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
                  );
                },
                childCount: displayedPosts.length,
              ),
            )
        ],
      ),
    );
  }

  void _showEditPetSheet(BuildContext context, PetModel pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditPetSheet(pet: pet),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Empty state: Prompt user to add their first pet
// ─────────────────────────────────────────────────────────
class _EmptyPetsCta extends StatelessWidget {
  final VoidCallback onAddPet;

  const _EmptyPetsCta({required this.onAddPet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF8A65).withAlpha(51),
                  const Color(0xFF4FC3F7).withAlpha(51),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.pets, size: 48, color: Color(0xFFFF8A65)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Pets Yet!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first pet to start sharing photos,\nfinding matches, and connecting with others.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAddPet,
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Your First Pet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A65),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Edit Pet Bottom Sheet (simple inline edit)
// ─────────────────────────────────────────────────────────
class _EditPetSheet extends ConsumerStatefulWidget {
  final PetModel pet;

  const _EditPetSheet({required this.pet});

  @override
  ConsumerState<_EditPetSheet> createState() => _EditPetSheetState();
}

class _EditPetSheetState extends ConsumerState<_EditPetSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _breedController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _bioController = TextEditingController(text: widget.pet.bio);
    _breedController = TextEditingController(text: widget.pet.breed);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final fields = <String, dynamic>{};
      if (_nameController.text.trim() != widget.pet.name) {
        fields['name'] = _nameController.text.trim();
      }
      if (_bioController.text.trim() != widget.pet.bio) {
        fields['bio'] = _bioController.text.trim();
      }
      if (_breedController.text.trim() != widget.pet.breed) {
        fields['breed'] = _breedController.text.trim();
      }

      if (fields.isNotEmpty) {
        await ref.read(petProvider.notifier).reload();
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Profile updated!'),
              ],
            ),
            backgroundColor: const Color(0xFF81C784),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Edit Pet Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Breed', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _breedController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Bio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Pet Profile Info Chips
// ─────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Carousel Avatars
// ─────────────────────────────────────────────────────────
class _OwnerCarouselAvatar extends StatelessWidget {
  final String name;
  final bool isSelected;
  
  const _OwnerCarouselAvatar({required this.name, required this.isSelected});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop'),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}


class _PetCarouselAvatar extends StatelessWidget {
  final PetModel pet;
  final bool isSelected;
  
  const _PetCarouselAvatar({required this.pet, required this.isSelected});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: pet.profileImageUrl.isNotEmpty
                  ? NetworkImage(pet.profileImageUrl)
                  : null,
              backgroundColor: Colors.grey.shade200,
              child: pet.profileImageUrl.isEmpty
                  ? Text(pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(pet.name, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _AddPetAvatar extends StatelessWidget {
  const _AddPetAvatar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF8A65).withAlpha(77),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFFF8A65).withAlpha(26),
              child: const Icon(Icons.add_rounded, color: Color(0xFFFF8A65), size: 28),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Add Pet', style: TextStyle(fontSize: 12, color: Color(0xFFFF8A65), fontWeight: FontWeight.w600)),
        ],
      ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
