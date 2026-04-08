import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/pet_model.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../utils/image_upload_helper.dart';
import '../utils/supabase_config.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  String? selectedPetId;
  File? _selectedFile;
  bool _isUploading = false;
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImageUploadHelper.pickFromGallery();
    if (file == null) return;
    setState(() {
      _selectedFile = file;
    });
  }

  Future<void> _sharePost(List<PetModel> myPets) async {
    if (selectedPetId == null ||
        _selectedFile == null ||
        _captionController.text.trim().isEmpty) {
      return;
    }

    final pet = myPets.firstWhere((p) => p.id == selectedPetId);

    setState(() => _isUploading = true);
    try {
      // Upload to Supabase Storage
      final ext = _selectedFile!.path.split('.').last;
      final path = '${pet.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final mediaUrl = await ImageUploadHelper.upload(
        file: _selectedFile!,
        bucket: kBucketPostMedia,
        path: path,
      );

      // Create post with uploaded URL
      await ref
          .read(feedProvider.notifier)
          .addPost(pet, mediaUrl, _captionController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post successfully shared!')),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);
    final myPets = petState.myPets;

    // Default select the first pet if none selected
    if (selectedPetId == null && myPets.isNotEmpty) {
      selectedPetId = myPets.first.id;
    }

    final isReadyToShare =
        selectedPetId != null &&
        _selectedFile != null &&
        _captionController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: FilledButton(
              onPressed: (isReadyToShare && !_isUploading)
                  ? () => _sharePost(myPets)
                  : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Share',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 8.0),
              child: Text(
                'Posting as...',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            if (myPets.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Create a pet profile first to post!',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              SizedBox(
                height: 115,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: myPets.length,
                  itemBuilder: (context, index) {
                    final pet = myPets[index];
                    final isSelected = pet.id == selectedPetId;
                    return GestureDetector(
                      onTap: () => setState(() => selectedPetId = pet.id),
                      child: _AuthorAvatar(pet: pet, isSelected: isSelected),
                    );
                  },
                ),
              ),
            const Divider(height: 1),

            // Photo Upload Region
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    image: _selectedFile != null
                        ? DecorationImage(
                            image: FileImage(_selectedFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to select a photo',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // Caption Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _captionController,
                maxLength: 2000,
                maxLines: 6,
                minLines: 1,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),

            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.location_on_outlined,
                color: Colors.black87,
              ),
              title: const Text(
                'Add Location',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black87),
              title: const Text(
                'Tag other Pets',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
            const SizedBox(height: 40),
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
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: pet.profileImageUrl.isNotEmpty
                  ? NetworkImage(pet.profileImageUrl)
                  : null,
              child: pet.profileImageUrl.isEmpty ? Text(pet.name[0]) : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pet.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
