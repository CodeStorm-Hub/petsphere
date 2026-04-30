import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/pet_model.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../utils/image_upload_helper.dart';
import '../utils/media_utils.dart';
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
  PostMediaType _selectedMediaType = PostMediaType.image;
  String _location = '';
  final Set<String> _taggedPetIds = {};
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

  void _setSelectedMedia(File file) {
    setState(() {
      _selectedFile = file;
      _selectedMediaType = postMediaTypeFromPath(file.path);
    });
  }

  List<PetModel> _taggedPets(List<PetModel> pets) {
    return pets.where((pet) => _taggedPetIds.contains(pet.id)).toList();
  }

  Future<void> _showLocationSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationSheetContent(initialLocation: _location),
    );

    if (!mounted || result == null) return;
    setState(() => _location = result);
  }

  Future<void> _showTagPetsSheet(List<PetModel> myPets) async {
    final availablePets =
        myPets.where((pet) => pet.id != selectedPetId).toList();
    if (availablePets.isEmpty) {
      _showError('Add another pet before tagging.');
      return;
    }

    final draftTaggedPetIds = Set<String>.from(_taggedPetIds);
    final selectedPetIds = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final screenHeight = MediaQuery.sizeOf(ctx).height;
        final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: _ComposerSheet(
                title: 'Tag Other Pets',
                subtitle: 'Mention pets who are part of this post.',
                child: SizedBox(
                  height: screenHeight * 0.45,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: availablePets.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: Color(0xFF2E2B26)),
                          itemBuilder: (context, index) {
                            final pet = availablePets[index];
                            final selected = draftTaggedPetIds.contains(pet.id);
                            return CheckboxListTile(
                              value: selected,
                              activeColor: const Color(0xFFD4845A),
                              contentPadding: EdgeInsets.zero,
                              secondary: CircleAvatar(
                                backgroundImage: pet.profileImageUrl.isNotEmpty
                                    ? NetworkImage(pet.profileImageUrl)
                                    : null,
                                backgroundColor: const Color(0xFF211F1B),
                                child: pet.profileImageUrl.isEmpty
                                    ? Text(
                                        pet.name.isNotEmpty
                                            ? pet.name[0].toUpperCase()
                                            : '?',
                                      )
                                    : null,
                              ),
                              title: Text(
                                pet.name,
                                style: const TextStyle(
                                  color: Color(0xFFF2EDE4),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                pet.breed,
                                style:
                                    const TextStyle(color: Color(0xFFB8B0A4)),
                              ),
                              onChanged: (_) {
                                setSheetState(() {
                                  selected
                                      ? draftTaggedPetIds.remove(pet.id)
                                      : draftTaggedPetIds.add(pet.id);
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(draftTaggedPetIds.clear);
                              },
                              child: const Text('Clear'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => Navigator.pop(
                                  ctx, Set<String>.from(draftTaggedPetIds)),
                              child: const Text('Done'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || selectedPetIds == null) return;
    setState(() {
      _taggedPetIds
        ..clear()
        ..addAll(selectedPetIds);
    });
  }

  void _showMediaSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1814),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF2E2B26)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF625E59),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Text(
                    'Add Media',
                    style: TextStyle(
                      color: Color(0xFFF2EDE4),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.auto_awesome, color: Color(0xFFD4845A)),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose a photo or video for your post.',
                  style: TextStyle(color: Color(0xFFB8B0A4)),
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _MediaSourceTile(
                    icon: Icons.photo_library_rounded,
                    title: 'Gallery',
                    subtitle: 'Photo',
                    color: const Color(0xFFD4845A),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final file = await ImageUploadHelper.pickFromGallery();
                      if (file != null) _setSelectedMedia(file);
                    },
                  ),
                  _MediaSourceTile(
                    icon: Icons.camera_alt_rounded,
                    title: 'Camera',
                    subtitle: 'Photo',
                    color: const Color(0xFF4FC3F7),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final file = await ImageUploadHelper.pickFromCamera();
                      if (file != null) _setSelectedMedia(file);
                    },
                  ),
                  _MediaSourceTile(
                    icon: Icons.video_library_rounded,
                    title: 'Library',
                    subtitle: 'Video',
                    color: const Color(0xFF9575CD),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final file =
                          await ImageUploadHelper.pickVideoFromGallery();
                      if (file != null) _setSelectedMedia(file);
                    },
                  ),
                  _MediaSourceTile(
                    icon: Icons.videocam_rounded,
                    title: 'Record',
                    subtitle: 'Video',
                    color: const Color(0xFF4DB6AC),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final file =
                          await ImageUploadHelper.pickVideoFromCamera();
                      if (file != null) _setSelectedMedia(file);
                    },
                  ),
                ],
              ),
            ],
          ),
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
      _showError('Please add a photo or video');
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

      await ref.read(feedProvider.notifier).addPost(
            pet,
            mediaUrl,
            _captionController.text.trim(),
            location: _location,
            taggedPetIds: _taggedPetIds.toList(),
            taggedPetNames: _taggedPets(myPets).map((pet) => pet.name).toList(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Posted as ${pet.name}!'),
              ],
            ),
            backgroundColor: const Color(0xFF81C784),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    if (selectedPetId == null && myPets.isNotEmpty) {
      selectedPetId = myPets.first.id;
    }
    _taggedPetIds.remove(selectedPetId);
    final taggedPets = _taggedPets(myPets);

    final isReadyToShare = selectedPetId != null &&
        _selectedFile != null &&
        _captionController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E0B),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFFF2EDE4),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _CloseComposerButton(
            onPressed: () => context.pop(),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Post',
              style:
                  TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
            ),
            Text(
              'Share a fresh pet moment',
              style: TextStyle(fontSize: 12, color: Color(0xFFB8B0A4)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _GradientShareButton(
              enabled: isReadyToShare && !_isUploading,
              isLoading: _isUploading,
              onPressed: () => _sharePost(myPets),
            ),
          ),
        ],
      ),
      body: myPets.isEmpty
          ? _EmptyPetsState(
              onAddPet: () {
                context.pop();
                context.push('/add_pet');
              },
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top + kToolbarHeight + 24,
                16,
                32 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ComposerHero(),
                      const SizedBox(height: 20),
                      const _SectionLabel('Posting as'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: myPets.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final pet = myPets[index];
                            final isSelected = pet.id == selectedPetId;
                            return GestureDetector(
                              onTap: () => setState(() {
                                selectedPetId = pet.id;
                                _taggedPetIds.remove(pet.id);
                              }),
                              child: _AuthorAvatar(
                                pet: pet,
                                isSelected: isSelected,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _MediaComposerCard(
                        file: _selectedFile,
                        mediaType: _selectedMediaType,
                        onTap: _showMediaSourceSheet,
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: FilledButton.tonalIcon(
                            onPressed: _showMediaSourceSheet,
                            icon:
                                const Icon(Icons.swap_horiz_rounded, size: 18),
                            label: const Text('Change Media'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const _SectionLabel('Caption'),
                      const SizedBox(height: 10),
                      _CaptionCard(
                        controller: _captionController,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      _PostOptionsCard(
                        location: _location,
                        taggedPets: taggedPets,
                        onLocationTap: _showLocationSheet,
                        onTagTap: () => _showTagPetsSheet(myPets),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _CloseComposerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseComposerButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1814).withAlpha(230),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF2E2B26)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFFF2EDE4),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposerSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ComposerSheet({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1814),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2E2B26)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF625E59),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFF2EDE4),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Color(0xFFB8B0A4))),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _GradientShareButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientShareButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4845A), Color(0xFFB86A44)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33D4845A),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isLoading
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ComposerHero extends StatelessWidget {
  const _ComposerHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF211F1B), Color(0xFF171511)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Color(0xFF2E2B26)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0x33D4845A),
            child: Icon(Icons.auto_awesome, color: Color(0xFFD4845A)),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build a beautiful post',
                  style: TextStyle(
                    color: Color(0xFFF2EDE4),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose your pet, add media, then tell the story.',
                  style: TextStyle(color: Color(0xFFB8B0A4), height: 1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFF2EDE4),
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _MediaComposerCard extends StatelessWidget {
  final File? file;
  final PostMediaType mediaType;
  final VoidCallback onTap;

  const _MediaComposerCard({
    required this.file,
    required this.mediaType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedia = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFD4845A), Color(0xFF4A7C59), Color(0xFF2E2B26)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1814),
                    image: hasMedia && mediaType == PostMediaType.image
                        ? DecorationImage(
                            image: FileImage(file!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                if (!hasMedia)
                  const _EmptyMediaPrompt()
                else if (mediaType == PostMediaType.video)
                  const _VideoMediaPrompt(),
                Positioned(
                  top: 14,
                  left: 14,
                  child: _PillBadge(
                    icon: hasMedia
                        ? (mediaType == PostMediaType.video
                            ? Icons.videocam_rounded
                            : Icons.image_rounded)
                        : Icons.add_photo_alternate_rounded,
                    label: hasMedia
                        ? (mediaType == PostMediaType.video ? 'Video' : 'Photo')
                        : 'Media',
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(160),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Tap to edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyMediaPrompt extends StatelessWidget {
  const _EmptyMediaPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.1,
          colors: [Color(0x33D4845A), Color(0xFF1A1814)],
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            size: 64,
            color: Color(0xFFD4845A),
          ),
          SizedBox(height: 16),
          Text(
            'Drop in a photo or video',
            style: TextStyle(
              color: Color(0xFFF2EDE4),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Gallery, camera, or video library',
            style: TextStyle(color: Color(0xFFB8B0A4)),
          ),
        ],
      ),
    );
  }
}

class _VideoMediaPrompt extends StatelessWidget {
  const _VideoMediaPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF211F1B), Color(0xFF0F0E0B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_fill_rounded,
              size: 82,
              color: Color(0xFFD4845A),
            ),
            SizedBox(height: 12),
            Text(
              'Video ready',
              style: TextStyle(
                color: Color(0xFFF2EDE4),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PillBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(160),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptionCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _CaptionCard({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1814),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2E2B26)),
      ),
      child: TextField(
        controller: controller,
        maxLength: 2000,
        maxLines: 6,
        minLines: 3,
        onChanged: (_) => onChanged(),
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Color(0xFFF2EDE4), fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'What happened today?',
          hintStyle: TextStyle(color: Color(0xFF756F66)),
          border: InputBorder.none,
          counterStyle: TextStyle(color: Color(0xFF756F66)),
        ),
      ),
    );
  }
}

class _PostOptionsCard extends StatelessWidget {
  final String location;
  final List<PetModel> taggedPets;
  final VoidCallback onLocationTap;
  final VoidCallback onTagTap;

  const _PostOptionsCard({
    required this.location,
    required this.taggedPets,
    required this.onLocationTap,
    required this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1814),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2E2B26)),
      ),
      child: Column(
        children: [
          _ComposerOptionTile(
            icon: Icons.location_on_outlined,
            title: 'Add location',
            subtitle: location.isEmpty ? 'Optional' : location,
            isActive: location.isNotEmpty,
            onTap: onLocationTap,
          ),
          const Divider(height: 1, color: Color(0xFF2E2B26)),
          _ComposerOptionTile(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Tag other pets',
            subtitle: taggedPets.isEmpty
                ? 'Optional'
                : taggedPets.map((pet) => pet.name).join(', '),
            isActive: taggedPets.isNotEmpty,
            onTap: onTagTap,
          ),
        ],
      ),
    );
  }
}

class _ComposerOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const _ComposerOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFD4845A).withAlpha(isActive ? 48 : 28),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFFD4845A)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFF2EDE4),
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFFB8B0A4), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFB8B0A4)),
    );
  }
}

class _EmptyPetsState extends StatelessWidget {
  final VoidCallback onAddPet;

  const _EmptyPetsState({required this.onAddPet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1814),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF2E2B26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pets, size: 64, color: Color(0xFFD4845A)),
              const SizedBox(height: 16),
              const Text(
                'Create a pet profile first',
                style: TextStyle(
                  color: Color(0xFFF2EDE4),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can only post as one of your pets. Add a pet profile to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB8B0A4)),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAddPet,
                icon: const Icon(Icons.add),
                label: const Text('Add a Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaSourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MediaSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF211F1B),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF2E2B26)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFF2EDE4),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFB8B0A4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.only(right: 12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4845A).withValues(alpha: 0.15)
              : const Color(0xFF211F1B),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFD4845A) : const Color(0xFF2E2B26),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: pet.profileImageUrl.isNotEmpty
                  ? NetworkImage(pet.profileImageUrl)
                  : null,
              child: pet.profileImageUrl.isEmpty
                  ? Text(
                      pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              pet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFFF2EDE4)
                    : const Color(0xFFB8B0A4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSheetContent extends StatefulWidget {
  final String initialLocation;
  const _LocationSheetContent({required this.initialLocation});

  @override
  State<_LocationSheetContent> createState() => _LocationSheetContentState();
}

class _LocationSheetContentState extends State<_LocationSheetContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLocation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: _ComposerSheet(
        title: 'Add Location',
        subtitle: 'Add where this moment happened.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Color(0xFFF2EDE4)),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Park, city, cafe...',
                hintStyle: TextStyle(color: Color(0xFF756F66)),
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFFD4845A),
                ),
                filled: true,
                fillColor: Color(0xFF211F1B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  borderSide: BorderSide(color: Color(0xFF2E2B26)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, _controller.text.trim()),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
