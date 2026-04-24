import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/pet_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../controllers/follow_controller.dart';
import '../utils/image_upload_helper.dart';
import '../utils/supabase_config.dart';

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
    ref.listen<String?>(profilePetNavigationProvider, (prev, next) {
      if (next != null) {
        setState(() => selectedId = next);
        ref.read(profilePetNavigationProvider.notifier).clear();
      }
    });

    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = user?.name ?? 'Pet Lover';

    // Real pets from petProvider
    final petState = ref.watch(petProvider);
    final myOwnedPets = petState.myPets;

    // Default to 'owner' view
    selectedId ??= 'owner';

    var isOwnerView = selectedId == 'owner';

    PetModel? selectedPet;
    if (!isOwnerView && myOwnedPets.isNotEmpty) {
      selectedPet = myOwnedPets.firstWhere(
        (p) => p.id == selectedId,
        orElse: () => myOwnedPets.first,
      );
    }

    // Safety: if we're in pet view but have no pet selected, fall back to owner
    if (!isOwnerView && selectedPet == null) {
      selectedId = 'owner';
      isOwnerView = true;
    }

    // Post grid from real FeedState
    final feedState = ref.watch(feedProvider);
    final myUserId = user?.id ?? '';
    final displayedPosts = isOwnerView
        ? feedState.posts.where((post) => post.pet.userId == myUserId).toList()
        : feedState.posts
            .where((post) => post.pet.id == selectedPet?.id)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnerView ? 'My Account' : (selectedPet?.name ?? 'Pet')),
        actions: [
          if (isOwnerView)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sign Out',
              onPressed: () => _showLogoutConfirmation(context),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(petProvider.notifier).reload(),
            ref.read(feedProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

                 // Horizontal Pet Carousel
                 SizedBox(
                   height: 115,
                   child: ListView.builder(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     scrollDirection: Axis.horizontal,
                     itemCount: myOwnedPets.length + 2,
                     itemBuilder: (context, index) {
                       if (index == 0) {
                         return GestureDetector(
                           onTap: () => setState(() => selectedId = 'owner'),
                           child: _OwnerCarouselAvatar(
                             user: user,
                             isSelected: isOwnerView,
                           ),
                         );
                       }

                       if (index == myOwnedPets.length + 1) {
                         return GestureDetector(
                           onTap: () => context.push('/add_pet'),
                           child: const _AddPetAvatar(),
                         );
                       }

                       final petIndex = index - 1;
                       final pet = myOwnedPets[petIndex];
                       final isSelected = pet.id == selectedId;

                       return GestureDetector(
                         onTap: () => setState(() => selectedId = pet.id),
                         child: _PetCarouselAvatar(pet: pet, isSelected: isSelected),
                       );
                     },
                   ),
                 ),

                 const Divider(),

                 // Active Context Summary
                 Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           // Dynamic owner/pet avatar
                           _buildAvatar(isOwnerView, user, selectedPet),
                           Expanded(
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                               children: [
                                 _StatColumn(label: 'Posts', value: '${displayedPosts.length}'),
                                  if (isOwnerView) ...[
                                    ref.watch(ownerFollowerCountProvider(myUserId)).when(
                                          data: (count) => _StatColumn(label: "Followers", value: "$count"),
                                          loading: () => const _StatColumn(label: "Followers", value: "..."),
                                          error: (_, __) => const _StatColumn(label: "Followers", value: "0"),
                                        ),
                                    ref.watch(followingCountProvider(myUserId)).when(
                                          data: (count) => _StatColumn(label: "Following", value: "$count"),
                                          loading: () => const _StatColumn(label: "Following", value: "..."),
                                          error: (_, __) => const _StatColumn(label: "Following", value: "0"),
                                        ),
                                  ] else ...[
                                    _StatColumn(label: "Pets", value: "${myOwnedPets.length}"),
                                    if (selectedPet != null)
                                      ref.watch(petFollowerCountProvider(selectedPet.id)).when(
                                            data: (count) => _StatColumn(label: "Followers", value: "$count"),
                                            loading: () => const _StatColumn(label: "Followers", value: "..."),
                                            error: (_, __) => const _StatColumn(label: "Followers", value: "0"),
                                          ),
                                  ],
                               ],
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 12),

                       // Dynamic name
                       Text(
                         isOwnerView ? userName : (selectedPet?.name ?? ''),
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                       ),

                       // Owner email
                       if (isOwnerView && user?.email != null && user!.email.isNotEmpty)
                         Text(
                           user.email,
                           style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                         ),

                       if (!isOwnerView && selectedPet != null)
                         Text(
                           selectedPet.breed,
                           style: TextStyle(
                             color: Theme.of(context).colorScheme.primary,
                             fontWeight: FontWeight.bold,
                           ),
                         ),

                       const SizedBox(height: 6),

                       // Dynamic bio
                       Text(
                         isOwnerView
                             ? (user?.bio?.isNotEmpty == true
                                 ? user!.bio!
                                 : 'Tap "Edit Account" to add a bio!')
                             : (selectedPet?.bio ?? ''),
                         style: TextStyle(
                           color: isOwnerView && (user?.bio?.isEmpty ?? true)
                               ? Colors.grey.shade400
                               : null,
                           fontStyle: isOwnerView && (user?.bio?.isEmpty ?? true)
                               ? FontStyle.italic
                               : null,
                         ),
                       ),

                       // Owner info chips
                       if (isOwnerView) ...[
                         const SizedBox(height: 12),
                         Wrap(
                           spacing: 8,
                           runSpacing: 8,
                           children: [
                             _InfoChip(
                               icon: Icons.pets,
                               label: '${myOwnedPets.length} ${myOwnedPets.length == 1 ? 'Pet' : 'Pets'}',
                               color: const Color(0xFFFF8A65),
                             ),
                             if (user?.location?.isNotEmpty == true)
                               _InfoChip(
                                 icon: Icons.location_on_outlined,
                                 label: user!.location!,
                                 color: const Color(0xFF4FC3F7),
                               ),
                             _InfoChip(
                               icon: Icons.verified_user_outlined,
                               label: 'Verified',
                               color: const Color(0xFF81C784),
                             ),
                           ],
                         ),
                       ],

                       // Pet detail chips for non-owner view
                       if (!isOwnerView && selectedPet != null) ...[
                         const SizedBox(height: 12),
                         Wrap(
                           spacing: 8,
                           runSpacing: 8,
                           children: [
                             _InfoChip(
                               icon: Icons.pets,
                               label: selectedPet.animalType,
                               color: const Color(0xFFFF8A65),
                             ),
                             _InfoChip(
                               icon: Icons.cake_outlined,
                               label: '${selectedPet.age} ${selectedPet.age == 1 ? 'year' : 'years'} old',
                               color: const Color(0xFF4FC3F7),
                             ),
                             if (selectedPet.isPublicOwner)
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
                                 if (isOwnerView) {
                                   _showEditOwnerSheet(context, user);
                                 } else if (selectedPet != null) {
                                   _showEditPetSheet(context, selectedPet);
                                 }
                               },
                               child: Text(isOwnerView ? 'Edit Account' : 'Edit Profile'),
                             ),
                           ),
                           const SizedBox(width: 8),
                           Expanded(
                             child: OutlinedButton(
                               onPressed: () {
                                 if (isOwnerView) {
                                   _showProfileShareSheet(
                                     context,
                                     'https://petsphere.app/user/${user?.id ?? ''}',
                                     userName,
                                   );
                                 } else if (selectedPet != null) {
                                   _showProfileShareSheet(
                                     context,
                                     'https://petsphere.app/pet/${selectedPet.id}',
                                     selectedPet.name,
                                   );
                                 }
                               },
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
                      if (!isOwnerView && selectedPet != null) ...[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.push('/create_post?petId=${selectedPet!.id}'),
                          icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                          label: const Text('Create Post'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A65),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
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
                  return GestureDetector(
                    onTap: () => context.push('/post/${post.id}'),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          post.mediaUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
                        ),
                        if (isOwnerView)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: post.pet.profileImageUrl.isNotEmpty
                                  ? NetworkImage(post.pet.profileImageUrl)
                                  : null,
                              child: post.pet.profileImageUrl.isEmpty
                                  ? Text(post.pet.name.isNotEmpty ? post.pet.name[0] : '?',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  );
                },
                childCount: displayedPosts.length,
              ),
            )
        ],
        ),
      ),
      floatingActionButton: !isOwnerView && selectedPet != null
          ? FloatingActionButton(
              heroTag: 'profile_fab',
              onPressed: () => context.push('/create_post?petId=${selectedPet!.id}'),
              backgroundColor: const Color(0xFFFF8A65),
              child: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
            )
          : null,
    );
  }

  void _showProfileShareSheet(BuildContext context, String shareLink, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share $name',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF8A65).withAlpha(26),
                  ),
                  child: const Icon(Icons.link, color: Color(0xFFFF8A65)),
                ),
                title: const Text('Copy Profile Link'),
                subtitle: Text(
                  shareLink,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: shareLink));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Link copied to clipboard!'),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF81C784),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4FC3F7).withAlpha(26),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF4FC3F7)),
                ),
                title: const Text('Send in Message'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/messages');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF81C784).withAlpha(26),
                  ),
                  child: const Icon(Icons.qr_code, color: Color(0xFF81C784)),
                ),
                title: const Text('QR Code'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code coming soon!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(bool isOwnerView, UserModel? user, PetModel? selectedPet) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: isOwnerView
            ? const Color(0xFFFF8A65).withAlpha(26)
            : Colors.white,
        backgroundImage: isOwnerView
            ? (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty
                ? NetworkImage(user.profileImageUrl!)
                : null)
            : (selectedPet != null && selectedPet.profileImageUrl.isNotEmpty
                ? NetworkImage(selectedPet.profileImageUrl)
                : null),
        child: isOwnerView && (user?.profileImageUrl == null || user!.profileImageUrl!.isEmpty)
            ? Text(
                user?.initials ?? '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8A65),
                ),
              )
            : (!isOwnerView && (selectedPet == null || selectedPet.profileImageUrl.isEmpty)
                ? Icon(Icons.pets, size: 32, color: Colors.grey.shade400)
                : null),
      ),
    );
  }

  void _showEditOwnerSheet(BuildContext context, UserModel? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditOwnerSheet(user: user),
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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Edit Owner Profile Bottom Sheet
// ─────────────────────────────────────────────────────────
class _EditOwnerSheet extends ConsumerStatefulWidget {
  final UserModel user;

  const _EditOwnerSheet({required this.user});

  @override
  ConsumerState<_EditOwnerSheet> createState() => _EditOwnerSheetState();
}

class _EditOwnerSheetState extends ConsumerState<_EditOwnerSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  File? _newAvatar;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _locationController = TextEditingController(text: widget.user.location ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await ImageUploadHelper.pickFromGallery();
    if (file != null) {
      setState(() => _newAvatar = file);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final fields = <String, dynamic>{};

      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && newName != (widget.user.name ?? '')) {
        fields['name'] = newName;
      }

      final newBio = _bioController.text.trim();
      if (newBio != (widget.user.bio ?? '')) {
        fields['bio'] = newBio;
      }

      final newLocation = _locationController.text.trim();
      if (newLocation != (widget.user.location ?? '')) {
        fields['location'] = newLocation;
      }

      // Upload new avatar if selected
      if (_newAvatar != null) {
        try {
          final avatarUrl = await authRepository.uploadAvatar(
            widget.user.id,
            _newAvatar!,
          );
          fields['profile_image_url'] = avatarUrl;
        } catch (e) {
          debugPrint('Avatar upload failed: $e');
          if (mounted) {
            final reason = e.toString();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Avatar upload failed: ${reason.length > 100 ? '${reason.substring(0, 100)}…' : reason}',
                ),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }

      if (fields.isEmpty) {
        if (mounted) Navigator.pop(context);
        return;
      }

      debugPrint('Updating profile with fields: $fields');
      final success = await ref.read(authProvider.notifier).updateProfile(fields);

      if (mounted) {
        if (success) {
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
        } else {
          final authError = ref.read(authProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: ${authError ?? 'Unknown error'}'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
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
    final currentAvatarUrl = widget.user.profileImageUrl;
    final hasAvatar = currentAvatarUrl != null && currentAvatarUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 60),
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
            // Drag handle
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
              'Edit Account',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Avatar picker
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFFF8A65).withAlpha(26),
                      backgroundImage: _newAvatar != null
                          ? FileImage(_newAvatar!)
                          : (hasAvatar ? NetworkImage(currentAvatarUrl) : null) as ImageProvider?,
                      child: (_newAvatar == null && !hasAvatar)
                          ? Text(
                              widget.user.initials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF8A65),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to change photo',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),

            // Name
            _SheetFieldLabel(icon: Icons.badge_outlined, label: 'Display Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _sheetInputDecoration('Your name'),
            ),
            const SizedBox(height: 20),

            // Bio
            _SheetFieldLabel(icon: Icons.description_outlined, label: 'Bio'),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: _sheetInputDecoration('Tell others about yourself...'),
            ),
            const SizedBox(height: 20),

            // Location
            _SheetFieldLabel(icon: Icons.location_on_outlined, label: 'Location'),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              textCapitalization: TextCapitalization.words,
              decoration: _sheetInputDecoration('e.g. New York, NY'),
            ),
            const SizedBox(height: 28),

            // Save button
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  InputDecoration _sheetInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF8A65), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Edit Pet Bottom Sheet
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
  File? _newAvatar;
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

  Future<void> _pickAvatar() async {
    final file = await ImageUploadHelper.pickFromGallery();
    if (file != null) {
      setState(() => _newAvatar = file);
    }
  }

  Future<void> _takePhoto() async {
    final file = await ImageUploadHelper.pickFromCamera();
    if (file != null) {
      setState(() => _newAvatar = file);
    }
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
              'Change Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a new photo for your pet',
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
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar();
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

      if (_newAvatar != null) {
        try {
          final ext = _newAvatar!.path.split('.').last;
          final path = '${widget.pet.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
          final avatarUrl = await ImageUploadHelper.upload(
            file: _newAvatar!,
            bucket: kBucketPetImages,
            path: path,
          );
          fields['profile_image_url'] = avatarUrl;
        } catch (e) {
          debugPrint('Pet avatar upload failed: $e');
          if (mounted) {
            final reason = e.toString();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Photo upload failed: ${reason.length > 100 ? '${reason.substring(0, 100)}…' : reason}',
                ),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }

      if (fields.isEmpty) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final success = await ref.read(petProvider.notifier).updatePet(widget.pet.id, fields);

      if (mounted) {
        if (success) {
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
        } else {
          final petError = ref.read(petProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: ${petError ?? 'Unknown error'}'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
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
            const SizedBox(height: 24),

            Center(
              child: GestureDetector(
                onTap: _showImageSourceSheet,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _newAvatar != null
                          ? FileImage(_newAvatar!)
                          : (widget.pet.profileImageUrl.isNotEmpty
                              ? NetworkImage(widget.pet.profileImageUrl) as ImageProvider?
                              : null),
                      child: (_newAvatar == null && widget.pet.profileImageUrl.isEmpty)
                          ? Icon(Icons.pets, size: 32, color: Colors.grey.shade400)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to change photo',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),

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
// Shared Widgets
// ─────────────────────────────────────────────────────────

class _SheetFieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SheetFieldLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFF8A65)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }
}

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

class _OwnerCarouselAvatar extends StatelessWidget {
  final UserModel? user;
  final bool isSelected;

  const _OwnerCarouselAvatar({required this.user, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final hasImage = user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty;

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
              backgroundColor: const Color(0xFFFF8A65).withAlpha(26),
              backgroundImage: hasImage ? NetworkImage(user!.profileImageUrl!) : null,
              child: !hasImage
                  ? Text(
                      user?.initials ?? '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFF8A65),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text('All', style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
