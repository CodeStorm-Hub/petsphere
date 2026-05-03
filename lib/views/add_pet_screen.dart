import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pet_controller.dart';
import '../utils/image_upload_helper.dart';
import '../utils/supabase_config.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedAnimalType = 'Dog';
  File? _selectedImage;
  bool _isSaving = false;
  int _currentStep = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<_AnimalOption> _animalOptions = [
    _AnimalOption('Dog', Icons.pets),
    _AnimalOption('Cat', Icons.catching_pokemon),
    _AnimalOption('Bird', Icons.flutter_dash),
    _AnimalOption('Rabbit', Icons.cruelty_free),
    _AnimalOption('Fish', Icons.water),
    _AnimalOption('Other', Icons.emoji_nature),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImageUploadHelper.pickFromGallery();
    if (file != null) {
      setState(() => _selectedImage = file);
    }
  }

  Future<void> _takePhoto() async {
    final file = await ImageUploadHelper.pickFromCamera();
    if (file != null) {
      setState(() => _selectedImage = file);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              'Choose a source for your pet\'s photo',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: const Text('Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Select an existing photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt_rounded,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              title: const Text('Take a Photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Use your camera'),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Animal type selected, proceed
      setState(() => _currentStep = 1);
      _animController.reset();
      _animController.forward();
    } else if (_currentStep == 1) {
      // Validate name + breed
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your pet\'s name');
        return;
      }
      if (_breedController.text.trim().isEmpty) {
        _showError('Please enter the breed');
        return;
      }
      if (_ageController.text.trim().isEmpty) {
        _showError('Please enter age');
        return;
      }
      setState(() => _currentStep = 2);
      _animController.reset();
      _animController.forward();
    } else if (_currentStep == 2) {
      // Photo + bio step => submit
      _submitPet();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animController.reset();
      _animController.forward();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submitPet() async {
    setState(() => _isSaving = true);

    try {
      String profileImageUrl = '';

      // Upload image if selected — gracefully skip if bucket doesn't exist
      if (_selectedImage != null) {
        try {
          final ext = _selectedImage!.path.split('.').last;
          final path = 'new_pet/${DateTime.now().millisecondsSinceEpoch}.$ext';
          profileImageUrl = await ImageUploadHelper.upload(
            file: _selectedImage!,
            bucket: kBucketPetImages,
            path: path,
          );
        } catch (uploadError) {
          // Storage bucket may not exist — continue without image
          debugPrint(
              'Image upload failed (bucket may not exist): $uploadError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.onPrimary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Photo upload failed — saving pet without photo.')),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }

      final success = await ref.read(petProvider.notifier).createPet(
            name: _nameController.text.trim(),
            breed: _breedController.text.trim(),
            animalType: _selectedAnimalType,
            age: int.tryParse(_ageController.text.trim()) ?? 1,
            bio: _bioController.text.trim(),
            profileImageUrl: profileImageUrl,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  Text('${_nameController.text.trim()} added successfully!'),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.pop();
        } else {
          final petError = ref.read(petProvider).error;
          _showError(petError ?? 'Failed to add pet. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Add New Pet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_currentStep < 2)
            TextButton(
              onPressed: _nextStep,
              child: const Text(
                'Next',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressBar(),

          // Step content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _stepTitle(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Step ${_currentStep + 1} of 3',
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Step ${_currentStep + 1} of 3: ${_stepTitle()}',
            value: '${((_currentStep + 1) / 3 * 100).round()} percent complete',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                minHeight: 4,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Choose Animal Type';
      case 1:
        return 'Pet Details';
      case 2:
        return 'Photo & Bio';
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildAnimalTypeStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildPhotoBioStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────
  // Step 1: Animal Type Selection
  // ─────────────────────────────────────────────────────────
  Widget _buildAnimalTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What type of pet\nare you adding?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the animal type that best describes your pet.',
            style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _animalOptions.length,
            itemBuilder: (context, index) {
              final option = _animalOptions[index];
              final isSelected = _selectedAnimalType == option.label;
              final optionColor = Theme.of(context).colorScheme.primary;
              return Semantics(
                button: true,
                selected: isSelected,
                label: option.label,
                onTap: () => setState(() => _selectedAnimalType = option.label),
                child: ExcludeSemantics(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedAnimalType = option.label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? optionColor.withAlpha(26)
                            : Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? optionColor : Theme.of(context).colorScheme.onSurfaceVariant,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: optionColor.withAlpha(51),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option.icon,
                            size: 36,
                            color: isSelected ? optionColor : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                              color:
                                  isSelected ? optionColor : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Step 2: Name, Breed, Age
  // ─────────────────────────────────────────────────────────
  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about\nyour pet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in some basic info so others can get to know them.',
              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // Name
            _buildInputLabel('Name', Icons.badge_outlined),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('e.g. Buddy, Luna, Tweety'),
            ),
            const SizedBox(height: 24),

            // Breed
            _buildInputLabel('Breed', Icons.category_outlined),
            const SizedBox(height: 8),
            TextFormField(
              controller: _breedController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('e.g. Golden Retriever, Maine Coon'),
            ),
            const SizedBox(height: 24),

            // Age
            _buildInputLabel('Age (years)', Icons.cake_outlined),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g. 3'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Step 3: Photo & Bio
  // ─────────────────────────────────────────────────────────
  Widget _buildPhotoBioStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Almost done!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a photo and a short bio for your pet.',
            style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // Photo picker
          Center(
            child: GestureDetector(
              onTap: _showImageSourceSheet,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      border: Border.all(
                        color: _selectedImage != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: _selectedImage != null ? 3 : 2,
                      ),
                      boxShadow: _selectedImage != null
                          ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ]
                          : [],
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload Photo',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  if (_selectedImage == null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                        ),
                        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_selectedImage != null)
            Center(
              child: TextButton.icon(
                onPressed: _showImageSourceSheet,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Change Photo'),
              ),
            ),
          const SizedBox(height: 32),

          // Bio
          _buildInputLabel('Bio', Icons.description_outlined),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            minLines: 3,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              'Tell others about your pet\'s personality, quirks, and what makes them special...',
            ),
          ),
          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _isSaving ? null : _submitPet,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pets, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Add ${_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Pet'}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────
  Widget _buildInputLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}

class _AnimalOption {
  final String label;
  final IconData icon;

  const _AnimalOption(this.label, this.icon);
}
