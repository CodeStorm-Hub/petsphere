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
        final colorScheme = Theme.of(sheetContext).colorScheme;
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: colorScheme.outlineVariant),
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
                                color: colorScheme.outline,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Choose Story Media',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pick a photo or video to post as a story.',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _DurationBadge(
                                icon: Icons.image_outlined,
                                label: '7 s / photo',
                              ),
                              const SizedBox(width: 8),
                              _DurationBadge(
                                icon: Icons.videocam_outlined,
                                label: 'max 60 s / video',
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _MediaPickerTile(
                            icon: Icons.photo_library_outlined,
                            title: 'Choose Photo',
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final file =
                                  await ImageUploadHelper.pickFromGallery();
                              if (file != null) _setSelectedMedia(file);
                            },
                          ),
                          _MediaPickerTile(
                            icon: Icons.camera_alt_outlined,
                            title: 'Take Photo',
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final file =
                                  await ImageUploadHelper.pickFromCamera();
                              if (file != null) _setSelectedMedia(file);
                            },
                          ),
                          _MediaPickerTile(
                            icon: Icons.video_library_outlined,
                            title: 'Choose Video',
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final file = await ImageUploadHelper
                                  .pickVideoFromGallery();
                              if (file != null) _setSelectedMedia(file);
                            },
                          ),
                          _MediaPickerTile(
                            icon: Icons.videocam_outlined,
                            title: 'Record Video',
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final file =
                                  await ImageUploadHelper.pickVideoFromCamera();
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
      final path =
          'stories/${pet.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
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
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petProvider).myPets;
    final colorScheme = Theme.of(context).colorScheme;
    if (_selectedPetId == null && pets.isNotEmpty) {
      _selectedPetId = pets.first.id;
    }

    final canPublish =
        _selectedPetId != null && _selectedFile != null && !_isUploading;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 8,
        title: Text(
          'Create Story',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              onPressed: canPublish ? () => _publish(pets) : null,
              child: _isUploading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Share'),
            ),
          ),
        ],
      ),
      body: pets.isEmpty
          ? Center(
              child: Text(
                'Add a pet before posting a story.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.85),
                  radius: 1.3,
                  colors: [colorScheme.primary.withAlpha(50), colorScheme.surface.withAlpha(0)],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, _) {
                  final screenHeight = MediaQuery.sizeOf(context).height;
                  final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
                  final mediaCardHeight =
                      (screenHeight * 0.46).clamp(260.0, 460.0);

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ListView(
                        padding:
                            EdgeInsets.fromLTRB(16, 8, 16, 18 + keyboardInset),
                        children: [
                          Text(
                            'Post As',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
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
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final pet = pets[index];
                                final selected = pet.id == _selectedPetId;
                                return InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () =>
                                      setState(() => _selectedPetId = pet.id),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? colorScheme.primary
                                              .withAlpha(40)
                                          : colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: selected
                                            ? colorScheme.primary
                                            : colorScheme.outlineVariant,
                                        width: 1.4,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage:
                                              pet.profileImageUrl.isNotEmpty
                                                  ? NetworkImage(
                                                      pet.profileImageUrl)
                                                  : null,
                                          backgroundColor:
                                              colorScheme.surfaceContainerHighest,
                                          child: pet.profileImageUrl.isEmpty
                                              ? const Icon(Icons.pets, size: 14)
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          pet.name,
                                          style: TextStyle(
                                            color: selected
                                                ? colorScheme.onSurface
                                                : colorScheme.onSurfaceVariant,
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
                                color: colorScheme.surfaceContainer,
                                border:
                                    Border.all(color: colorScheme.outlineVariant),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withAlpha(128),
                                    blurRadius: 28,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                                image: _selectedFile != null &&
                                        _mediaType == PostMediaType.image
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
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline_rounded,
                                              size: 58,
                                              color: colorScheme.primary,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Tap to add photo or video',
                                              style: TextStyle(
                                                color: colorScheme.onSurface,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Gallery, camera, or video library',
                                              style: TextStyle(
                                                  color: colorScheme.onSurfaceVariant),
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
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.play_circle_fill_rounded,
                                                size: 74,
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Video selected',
                                                style: TextStyle(
                                                  color: colorScheme.onSurface,
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
                                          backgroundColor:
                                              Colors.black.withAlpha(120),
                                          foregroundColor:
                                              colorScheme.onSurface,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                        ),
                                        onPressed: _showMediaPicker,
                                        icon: const Icon(Icons.edit_rounded,
                                            size: 16),
                                        label: Text(
                                          _selectedFile == null
                                              ? 'Add'
                                              : 'Change',
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
                              color: colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(22),
                              border:
                                  Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: TextField(
                              controller: _captionController,
                              maxLength: 280,
                              maxLines: 3,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                counterStyle:
                                    TextStyle(color: colorScheme.onSurfaceVariant),
                                hintText: 'Write a caption...',
                                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
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
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colorScheme.primary.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DurationBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
