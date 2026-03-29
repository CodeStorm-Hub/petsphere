import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/pet_model.dart';
import '../controllers/feed_controller.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  String? selectedPetId;
  final TextEditingController _captionController = TextEditingController();
  
  // Dummy high-res photo URL for testing the visual "uploaded" state
  // We'll simulate finding a photo when they tap the upload box
  String? _selectedPhotoUrl;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _sharePost(List<PetModel> myPets) {
    if (selectedPetId == null || _selectedPhotoUrl == null || _captionController.text.trim().isEmpty) return;

    final pet = myPets.firstWhere((p) => p.id == selectedPetId);
    
    // Add to social feed
    ref.read(feedProvider.notifier).addPost(
      pet,
      _selectedPhotoUrl!,
      _captionController.text.trim(),
    );
    
    // Switch to feed screen (index 0) and remove this from stack
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post successfully shared!')),
    );
    context.go('/home');
  }

  void _simulatePhotoSelect() {
    setState(() {
      // Dummy generic pet photo placeholder representing chosen camera roll image
      _selectedPhotoUrl = 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=600&auto=format&fit=crop';
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = 'user-1'; // Authenticated mock human owner
    final myOwnedPets = mockPets.where((p) => p.userId == myUserId).toList();
    
    // Default select the first pet if none selected
    if (selectedPetId == null && myOwnedPets.isNotEmpty) {
      selectedPetId = myOwnedPets.first.id;
    }

    final isReadyToShare = selectedPetId != null && _selectedPhotoUrl != null && _captionController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Post', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton(
              onPressed: isReadyToShare ? () => _sharePost(myOwnedPets) : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Share', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Author Selection Row (Stories Style)
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 8.0),
              child: Text(
                'Posting as...',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
            SizedBox(
              height: 115, // Increased from 100 to fix 3px overflow
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: myOwnedPets.length,
                itemBuilder: (context, index) {
                  final pet = myOwnedPets[index];
                  final isSelected = pet.id == selectedPetId;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPetId = pet.id;
                      });
                    },
                    child: _AuthorAvatar(pet: pet, isSelected: isSelected),
                  );
                },
              ),
            ),
            
            const Divider(height: 1),

            // 2. Beautiful Photo Upload Region
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _simulatePhotoSelect,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _selectedPhotoUrl != null ? Colors.transparent : Colors.grey.shade300,
                      width: 2,
                      style: BorderStyle.none,
                    ),
                    image: _selectedPhotoUrl != null 
                     ? DecorationImage(
                         image: NetworkImage(_selectedPhotoUrl!),
                         fit: BoxFit.cover,
                       )
                     : null,
                  ),
                  child: _selectedPhotoUrl == null 
                   ? Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.add_photo_alternate_rounded, size: 64, color: Colors.grey.shade400),
                         const SizedBox(height: 16),
                         Text(
                           'Tap to select a photo',
                           style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: 16),
                         ),
                       ],
                     )
                   : const SizedBox.shrink(),
                ),
              ),
            ),

            // 3. Caption Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _captionController,
                maxLength: 2000,
                maxLines: 6,
                minLines: 1,
                onChanged: (_) => setState(() {}), // Refresh share button state
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  counterText: '', // Hide default character counter
                ),
              ),
            ),
            
            const Divider(),
            
            // 4. Extras
            ListTile(
              leading: const Icon(Icons.location_on_outlined, color: Colors.black87),
              title: const Text('Add Location', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black87),
              title: const Text('Tag other Pets', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
            const SizedBox(height: 40), // Padding for scroll
          ],
        ),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  final PetModel pet;
  final bool isSelected;
  
  const _AuthorAvatar({required this.pet, required this.isSelected});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(pet.profileImageUrl),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pet.name, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey.shade700
            )
          ),
        ],
      ),
    );
  }
}
