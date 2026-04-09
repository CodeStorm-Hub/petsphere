import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_model.dart';
import '../controllers/auth_controller.dart'; 

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
                         return _AddPetAvatar();
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
                       const SizedBox(height: 16),
                       
                       Row(
                         children: [
                           Expanded(
                             child: OutlinedButton(
                               onPressed: () {},
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
          
          // 4. Media Grid specifically mapping to the Selected Pet or Owner Array
          displayedPosts.isEmpty 
           ? SliverToBoxAdapter(
               child: Center(
                 child: Padding(
                   padding: const EdgeInsets.only(top: 40.0),
                   child: Text('No posts generated yet!', style: TextStyle(color: Colors.grey.shade500)),
                 ),
               ),
             )
           : SliverGrid(
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
                         errorBuilder: (ctx, _, _) => Container(color: Colors.grey.shade200),
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
}

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
              backgroundImage: NetworkImage(pet.profileImageUrl),
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.add, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Add Pet', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
