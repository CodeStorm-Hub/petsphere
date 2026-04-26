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

    final isReadyToShare = selectedPetId != null &&
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton(
              onPressed:
                  (isReadyToShare && !_isUploading) ? () => _sharePost(myPets) : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
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
                        color: Color(0xFFB8B0A4),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
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
                              Center(child: _AuthorAvatar(pet: pet, isSelected: isSelected)),
                        );
                      },
                    ),
                  ),
                  Divider(height: 1, color: const Color(0xFF2E2B26)),

                  // Photo upload
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: CustomPaint(
                        painter: _DashedRectPainter(color: const Color(0xFF2E2B26)),
                        child: Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1814),
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
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF211F1B),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_photo_alternate_rounded,
                                        size: 48,
                                        color: Color(0xFFD4845A),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Tap to add a photo',
                                      style: TextStyle(
                                        color: Color(0xFFF2EDE4),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Gallery or Camera',
                                      style: TextStyle(
                                        color: Color(0xFFB8B0A4),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
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
                        hintStyle: const TextStyle(
                            color: Color(0xFFB8B0A4), fontSize: 16),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),

                  const Divider(color: Color(0xFF2E2B26)),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined,
                        color: Color(0xFFF2EDE4)),
                    title: const Text('Add Location',
                        style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFF2EDE4))),
                    trailing:
                        const Icon(Icons.chevron_right, color: Color(0xFFB8B0A4)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: Color(0xFFF2EDE4)),
                    title: const Text('Tag other Pets',
                        style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFF2EDE4))),
                    trailing:
                        const Icon(Icons.chevron_right, color: Color(0xFFB8B0A4)),
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
      padding: const EdgeInsets.only(right: 12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4845A).withOpacity(0.15) : const Color(0xFF211F1B),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4845A) : const Color(0xFF2E2B26),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white),
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );

    path.addRRect(rrect);

    final dashPath = Path();
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    var distance = 0.0;
    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) => old.color != color;
}
