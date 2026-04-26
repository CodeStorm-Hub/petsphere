import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_model.dart';
import '../utils/image_upload_helper.dart';
import '../utils/media_utils.dart';
import '../utils/supabase_config.dart';

class CreateStoryScreen extends ConsumerStatefulWidget {
  final String? initialPetId;

  const CreateStoryScreen({super.key, this.initialPetId});

  @override
  ConsumerState<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  String? _selectedPetId;
  File? _selectedFile;
  PostMediaType _mediaType = PostMediaType.image;
  bool _isUploading = false;
  final _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPetId = widget.initialPetId;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _setSelectedMedia(File file) {
    setState(() {
      _selectedFile = file;
      _mediaType = postMediaTypeFromPath(file.path);
    });
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final mediaQuery = MediaQuery.of(sheetContext);
        final maxSheetHeight = mediaQuery.size.height * 0.85;

        return Padding(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF171617),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF2B292B)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxSheetHeight),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5F5A5F),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Choose Story Media',
                            style: TextStyle(
                              color: Color(0xFFF5F1EE),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pick a photo or video to post as a story.',
                            style: TextStyle(color: Color(0xFFB8B2AA)),
                          ),
                          const SizedBox(height: 18),
                          _MediaPickerTile(
                            icon: Icons.photo_library_outlined,
                            title: 'Choose Photo',
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final file = await ImageUploadHelper.pickFromGallery();
                              if (file != null) _setSelectedMedia(file);
                            },
                          ),
                          _MediaPickerTile(
                            icon: Icons.camera_alt_outlined,
                            title: 'Take Photo',
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final file = await ImageUploadHelper.pickFromCamera();
                              if (file != null) _setSelectedMedia(file);
                            },
                          ),
                          _MediaPickerTile(
                            icon: Icons.video_library_outlined,
                            title: 'Choose Video',
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final file = await ImageUploadHelper.pickVideoFromGallery();
                              if (file != null) _setSelectedMedia(file);
                            },
                          ),
                          _MediaPickerTile(
                            icon: Icons.videocam_outlined,
                            title: 'Record Video',
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final file = await ImageUploadHelper.pickVideoFromCamera();
                              if (file != null) _setSelectedMedia(file);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _publish(List<PetModel> pets) async {
    final selectedPetId = _selectedPetId;
    final selectedFile = _selectedFile;
    if (selectedPetId == null || selectedFile == null) return;

    final pet = pets.firstWhere((p) => p.id == selectedPetId);
    setState(() => _isUploading = true);
    try {
      final ext = selectedFile.path.split('.').last;
      final path = 'stories/${pet.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final mediaUrl = await ImageUploadHelper.upload(
        file: selectedFile,
        bucket: kBucketPostMedia,
        path: path,
      );

      final success = await ref.read(feedProvider.notifier).addStory(
            pet,
            mediaUrl,
            _captionController.text.trim(),
          );
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Story posted as ${pet.name}.')),
        );
        context.pop();
      } else {
        _showError(ref.read(feedProvider).error ?? 'Failed to post story.');
      }
    } catch (e) {
      if (mounted) _showError('Failed to post story: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petProvider).myPets;
    if (_selectedPetId == null && pets.isNotEmpty) {
      _selectedPetId = pets.first.id;
    }

    final canPublish = _selectedPetId != null && _selectedFile != null && !_isUploading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 8,
        title: const Text(
          'Create Story',
          style: TextStyle(
            color: Color(0xFFF5F1EE),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4845A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              onPressed: canPublish ? () => _publish(pets) : null,
              child: _isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Share'),
            ),
          ),
        ],
      ),
      body: pets.isEmpty
          ? const Center(
              child: Text(
                'Add a pet before posting a story.',
                style: TextStyle(color: Color(0xFFB8B2AA)),
              ),
            )
          : DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.85),
                  radius: 1.3,
                  colors: [Color(0x332A1B16), Color(0x000F0E10)],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, _) {
                  final screenHeight = MediaQuery.sizeOf(context).height;
                  final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
                  final mediaCardHeight = (screenHeight * 0.46).clamp(260.0, 460.0);

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 18 + keyboardInset),
                        children: [
                  const Text(
                    'Post As',
                    style: TextStyle(
                      color: Color(0xFFB8B2AA),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: pets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        final selected = pet.id == _selectedPetId;
                        return InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setState(() => _selectedPetId = pet.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFD4845A).withAlpha(40)
                                  : const Color(0xFF1C1A1D),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFD4845A)
                                    : const Color(0xFF2B292B),
                                width: 1.4,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: pet.profileImageUrl.isNotEmpty
                                      ? NetworkImage(pet.profileImageUrl)
                                      : null,
                                  backgroundColor: const Color(0xFF2A272A),
                                  child: pet.profileImageUrl.isEmpty
                                      ? const Icon(Icons.pets, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  pet.name,
                                  style: TextStyle(
                                    color: selected
                                        ? const Color(0xFFF5F1EE)
                                        : const Color(0xFFCAC4BD),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _showMediaPicker,
                            child: Container(
                              height: mediaCardHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFF1B191C),
                        border: Border.all(color: const Color(0xFF2B292B)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x80000000),
                            blurRadius: 28,
                            offset: Offset(0, 18),
                          ),
                        ],
                        image: _selectedFile != null && _mediaType == PostMediaType.image
                            ? DecorationImage(
                                image: FileImage(_selectedFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Stack(
                                  children: [
                            if (_selectedFile == null)
                              const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 58,
                                      color: Color(0xFFD4845A),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Tap to add photo or video',
                                      style: TextStyle(
                                        color: Color(0xFFF5F1EE),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Gallery, camera, or video library',
                                      style: TextStyle(color: Color(0xFFAEA79F)),
                                    ),
                                  ],
                                ),
                              )
                            else if (_mediaType == PostMediaType.video)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withAlpha(80),
                                      Colors.black.withAlpha(140),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.play_circle_fill_rounded,
                                        size: 74,
                                        color: Color(0xFFD4845A),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Video selected',
                                        style: TextStyle(
                                          color: Color(0xFFF5F1EE),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                                    Positioned(
                                      top: 14,
                                      right: 14,
                                      child: FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.black.withAlpha(120),
                                          foregroundColor: const Color(0xFFF5F1EE),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                        ),
                                        onPressed: _showMediaPicker,
                                        icon: const Icon(Icons.edit_rounded, size: 16),
                                        label: Text(
                                          _selectedFile == null ? 'Add' : 'Change',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B191C),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFF2B292B)),
                            ),
                            child: TextField(
                              controller: _captionController,
                              maxLength: 280,
                              maxLines: 3,
                              style: const TextStyle(color: Color(0xFFF5F1EE)),
                              decoration: const InputDecoration(
                                counterStyle: TextStyle(color: Color(0xFF9A948C)),
                                hintText: 'Write a caption...',
                                hintStyle: TextStyle(color: Color(0xFF88827B)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _MediaPickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MediaPickerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFD4845A).withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFD4845A)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFF5F1EE),
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFB8B2AA)),
    );
  }
}
