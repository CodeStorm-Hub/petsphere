import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_model.dart';
import '../utils/image_upload_helper.dart';
import '../utils/supabase_config.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? initialPetId;

  const CreatePostScreen({super.key, this.initialPetId});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  String? selectedPetId;
  File? _selectedFile;
  bool _isUploading = false;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedPetId = widget.initialPetId;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a source for your post photo',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A65).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library_rounded,
                    color: Color(0xFFFF8A65)),
              ),
              title: const Text('Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Select an existing photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await ImageUploadHelper.pickFromGallery();
                if (file != null) setState(() => _selectedFile = file);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Color(0xFF4FC3F7)),
              ),
              title: const Text('Take a Photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Use your camera'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await ImageUploadHelper.pickFromCamera();
                if (file != null) setState(() => _selectedFile = file);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePost(List<PetModel> myPets) async {
    if (selectedPetId == null) {
      _showError('Please select a pet to post as');
      return;
    }
    if (_selectedFile == null) {
      _showError('Please add a photo');
      return;
    }
    if (_captionController.text.trim().isEmpty) {
      _showError('Please write a caption');
      return;
    }

    final pet = myPets.firstWhere((p) => p.id == selectedPetId);

    setState(() => _isUploading = true);
    try {
      final ext = _selectedFile!.path.split('.').last;
      final path = '${pet.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final mediaUrl = await ImageUploadHelper.upload(
        file: _selectedFile!,
        bucket: kBucketPostMedia,
        path: path,
      );

      await ref
          .read(feedProvider.notifier)
          .addPost(pet, mediaUrl, _captionController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
<<<<<<< HEAD
            content: const Text('Post successfully shared!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
=======
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Posted as ${pet.name}!'),
              ],
            ),
            backgroundColor: const Color(0xFF81C784),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
>>>>>>> origin/main
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to share: $e');
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);
    final myPets = petState.myPets;
    final theme = Theme.of(context);

    if (selectedPetId == null && myPets.isNotEmpty) {
      selectedPetId = myPets.first.id;
    }

    final isReadyToShare = selectedPetId != null &&
        _selectedFile != null &&
        _captionController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton(
<<<<<<< HEAD
              onPressed: (isReadyToShare && !_isUploading)
                  ? () => _sharePost(myPets)
                  : null,
=======
              onPressed:
                  (isReadyToShare && !_isUploading) ? () => _sharePost(myPets) : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
>>>>>>> origin/main
              child: _isUploading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Share'),
            ),
          ),
        ],
      ),
<<<<<<< HEAD
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                'Posting as...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (myPets.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Create a pet profile first to post!',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
                      child: _AuthorAvatar(pet: pet, isSelected: isSelected, theme: theme),
                    );
                  },
                ),
              ),
            Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),

            // Photo Upload Region
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(32), // lg radius
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
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to select a photo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false, // Override the global filled setting for this specific field
                  counterText: '',
                  contentPadding: EdgeInsets.zero, // Remove padding to align with other elements
                ),
              ),
            ),

            Divider(color: theme.colorScheme.surfaceContainerHighest),
            ListTile(
              leading: Icon(Icons.location_on_outlined, color: theme.colorScheme.onSurface),
              title: Text('Add Location', style: theme.textTheme.titleMedium),
              trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: theme.colorScheme.onSurface),
              title: Text('Tag other Pets', style: theme.textTheme.titleMedium),
              trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
              onTap: () {},
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
=======
      body: myPets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Create a pet profile first',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can only post as one of your pets.\nAdd a pet profile to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        context.pop();
                        context.push('/add_pet');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add a Pet'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A65),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet selector
                  const Padding(
                    padding:
                        EdgeInsets.only(left: 16.0, top: 12.0, bottom: 8.0),
                    child: Text(
                      'Posting as...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
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
                          child:
                              _AuthorAvatar(pet: pet, isSelected: isSelected),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Photo upload
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: _showImageSourceSheet,
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
                                    'Tap to add a photo',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gallery or Camera',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),

                  if (_selectedFile != null)
                    Center(
                      child: TextButton.icon(
                        onPressed: _showImageSourceSheet,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Change Photo'),
                      ),
                    ),

                  // Caption
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _captionController,
                      maxLength: 2000,
                      maxLines: 6,
                      minLines: 1,
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write a caption...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 16),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),

                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined,
                        color: Colors.black87),
                    title: const Text('Add Location',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: Colors.black87),
                    title: const Text('Tag other Pets',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {},
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
>>>>>>> origin/main
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  final PetModel pet;
  final bool isSelected;
  final ThemeData theme;

  const _AuthorAvatar({required this.pet, required this.isSelected, required this.theme});

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
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: pet.profileImageUrl.isNotEmpty
                  ? NetworkImage(pet.profileImageUrl)
                  : null,
<<<<<<< HEAD
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: pet.profileImageUrl.isEmpty ? Icon(Icons.pets, color: theme.colorScheme.onSurfaceVariant) : null,
=======
              child: pet.profileImageUrl.isEmpty
                  ? Text(
                      pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  : null,
>>>>>>> origin/main
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pet.name,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
