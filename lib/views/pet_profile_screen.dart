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
import 'main_layout.dart' show bottomNavSpaceFor;

class PetProfileScreen extends ConsumerStatefulWidget {
  const PetProfileScreen({super.key});

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen> {
  // 'owner' represents the global master view. Null means uninitialized.
  String? selectedId;
  // Post category filter for pet view: null = All
  String? _postCategory;

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
    final allPetPosts = isOwnerView
        ? feedState.posts.where((post) => post.pet.userId == myUserId).toList()
        : feedState.posts.where((post) => post.pet.id == selectedPet?.id).toList();

    // Apply category filter (based on caption keyword matching)
    final displayedPosts = (_postCategory == null || isOwnerView)
        ? allPetPosts
        : allPetPosts.where((p) => p.caption.toLowerCase().contains(_postCategory!.toLowerCase())).toList();

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
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
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
          // ── Cover banner + profile header ──────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover banner hero image
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Cover image
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: () {
                        final coverUrl = isOwnerView
                            ? (user?.profileImageUrl ?? '')
                            : (selectedPet?.profileImageUrl ?? '');
                        return coverUrl.isNotEmpty
                            ? Image.network(
                                coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFFFAD93).withAlpha(80),
                                  child: const Center(
                                    child: Icon(Icons.pets, size: 60, color: Color(0xFF99472C)),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFFAD93), Color(0xFFFFE087)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.pets, size: 60, color: Color(0xFF99472C)),
                                ),
                              );
                      }(),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Color(0x33000000)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Profile avatar overlapping cover
                    Positioned(
                      bottom: -44,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFEF8F3), width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x2099472C),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _buildAvatar(isOwnerView, user, selectedPet),
                      ),
                    ),
                  ],
                ),
                // Spacer for avatar overlap
                const SizedBox(height: 52),

                // Pet carousel selector — content-sized so it never overflows
                // on any device, font scale, or accessibility setting.
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => selectedId = 'owner'),
                        child: _OwnerCarouselAvatar(
                          user: user,
                          isSelected: isOwnerView,
                        ),
                      ),
                      for (final pet in myOwnedPets)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => selectedId = pet.id),
                          child: _PetCarouselAvatar(
                            pet: pet,
                            isSelected: pet.id == selectedId,
                          ),
                        ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.push('/add_pet'),
                        child: const _AddPetAvatar(),
                      ),
                    ],
                  ),
                ),

                // Profile info section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + verified badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isOwnerView ? userName : (selectedPet?.name ?? ''),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Color(0xFF35322D),
                              ),
                            ),
                          ),
                          if (!isOwnerView && (selectedPet?.isVerified ?? false))
                            const Icon(Icons.verified, size: 22, color: Color(0xFF99472C)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Breed / email / location
                      if (isOwnerView && user?.email != null)
                        Text(
                          '${user!.email}${user.location?.isNotEmpty == true ? " · ${user.location}" : ""}',
                          style: const TextStyle(color: Color(0xFF625E59), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      if (!isOwnerView && selectedPet != null)
                        Text(
                          '${selectedPet.breed} · ${selectedPet.animalType}',
                          style: const TextStyle(color: Color(0xFF625E59), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      const SizedBox(height: 8),
                      // Bio
                      Text(
                        isOwnerView
                            ? (user?.bio?.isNotEmpty == true ? user!.bio! : 'Tap "Edit Account" to add a bio')
                            : (selectedPet?.bio.isNotEmpty == true ? selectedPet!.bio : 'No bio yet'),
                        style: TextStyle(
                          color: (isOwnerView && (user?.bio?.isEmpty ?? true)) ||
                                  (!isOwnerView && selectedPet?.bio.isEmpty == true)
                              ? const Color(0xFFB7B1AA)
                              : const Color(0xFF35322D),
                          fontSize: 14,
                          fontStyle: (isOwnerView && (user?.bio?.isEmpty ?? true))
                              ? FontStyle.italic
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        children: [
                          _StatColumn(label: 'Posts', value: '${displayedPosts.length}'),
                          const SizedBox(width: 28),
                          if (isOwnerView) ...[
                            ref.watch(ownerFollowerCountProvider(myUserId)).when(
                              data: (c) => _StatColumn(label: 'Followers', value: '$c'),
                              loading: () => const _StatColumn(label: 'Followers', value: '···'),
                              error: (_, __) => const _StatColumn(label: 'Followers', value: '0'),
                            ),
                            const SizedBox(width: 28),
                            ref.watch(followingCountProvider(myUserId)).when(
                              data: (c) => _StatColumn(label: 'Following', value: '$c'),
                              loading: () => const _StatColumn(label: 'Following', value: '···'),
                              error: (_, __) => const _StatColumn(label: 'Following', value: '0'),
                            ),
                          ] else if (selectedPet != null) ...[
                            ref.watch(petFollowerCountProvider(selectedPet.id)).when(
                              data: (c) => _StatColumn(label: 'Followers', value: '$c'),
                              loading: () => const _StatColumn(label: 'Followers', value: '···'),
                              error: (_, __) => const _StatColumn(label: 'Followers', value: '0'),
                            ),
                            const SizedBox(width: 28),
                            _StatColumn(label: 'Pets', value: '${myOwnedPets.length}'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action buttons
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
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF99472C),
                                side: const BorderSide(color: Color(0xFF99472C)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(isOwnerView ? 'Edit Account' : 'Edit Profile',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final link = isOwnerView
                                    ? 'https://petsphere.app/user/${user?.id ?? ''}'
                                    : 'https://petsphere.app/pet/${selectedPet?.id ?? ''}';
                                final name = isOwnerView ? userName : (selectedPet?.name ?? '');
                                _showProfileShareSheet(context, link, name);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF625E59),
                                side: const BorderSide(color: Color(0xFFB7B1AA)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(isOwnerView ? 'Share Account' : 'Share Profile',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Post category filter chips (tertiary styled) ─────
          if (!isOwnerView && selectedPet != null)
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    for (final cat in [null, 'Playtime', 'Nap', 'Outdoor', 'Food'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _postCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: _postCategory == cat
                                  ? const Color(0xFF506453)
                                  : const Color(0xFFE5FDE6),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              cat ?? 'All Posts',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _postCategory == cat
                                    ? const Color(0xFFE8FFE8)
                                    : const Color(0xFF4E6251),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Posts grid (bento / standard) ──────────────────
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
                      const Icon(Icons.camera_alt_outlined, size: 48, color: Color(0xFFB7B1AA)),
                      const SizedBox(height: 12),
                      const Text('No posts yet',
                          style: TextStyle(color: Color(0xFF625E59), fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        isOwnerView
                            ? 'Create a post to see it here.'
                            : 'Create a post as ${selectedPet?.name ?? 'this pet'}.',
                        style: const TextStyle(color: Color(0xFFB7B1AA), fontSize: 13),
                      ),
                      if (!isOwnerView && selectedPet != null) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.push('/create_post?petId=${selectedPet!.id}'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF99472C), Color(0xFF8A3B21)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Create Post',
                                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = displayedPosts[index];
                    return GestureDetector(
                      onTap: () => context.push('/post/${post.id}'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              post.mediaUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, _, __) => Container(
                                color: const Color(0xFFF3EDE6),
                                child: const Icon(Icons.image_outlined, color: Color(0xFFB7B1AA)),
                              ),
                            ),
                            if (isOwnerView)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: const Color(0xFFFEF8F3),
                                  backgroundImage: post.pet.profileImageUrl.isNotEmpty
                                      ? NetworkImage(post.pet.profileImageUrl)
                                      : null,
                                  child: post.pet.profileImageUrl.isEmpty
                                      ? Text(
                                          post.pet.name.isNotEmpty ? post.pet.name[0] : '?',
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF99472C)),
                                        )
                                      : null,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: displayedPosts.length,
                ),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: bottomNavSpaceFor(context))),
        ],
        ),
      ),
      floatingActionButton: !isOwnerView && selectedPet != null
          ? Padding(
              padding: EdgeInsets.only(bottom: bottomNavSpaceFor(context)),
              child: FloatingActionButton(
                heroTag: 'profile_fab',
                onPressed: () => context.push('/create_post?petId=${selectedPet!.id}'),
                backgroundColor: const Color(0xFFFF8A65),
                child: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
              ),
            )
          : null,
    );
  }

  void _showProfileShareSheet(BuildContext context, String shareLink, String name) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
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
                  color: colorScheme.outline.withAlpha(76),
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
                    color: colorScheme.primary.withAlpha(26),
                  ),
                  child: Icon(Icons.link, color: colorScheme.primary),
                ),
                title: const Text('Copy Profile Link'),
                subtitle: Text(
                  shareLink,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
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
                      backgroundColor:
                          Theme.of(context).snackBarTheme.backgroundColor,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.secondary.withAlpha(26),
                  ),
                  child: Icon(Icons.chat_bubble_outline, color: colorScheme.secondary),
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
                    color: colorScheme.tertiary.withAlpha(26),
                  ),
                  child: Icon(Icons.qr_code, color: colorScheme.tertiary),
                ),
                title: const Text('QR Code'),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text('Profile QR'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 140,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scan or copy this profile link',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            shareLink,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: shareLink));
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile link copied!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy Link'),
                        ),
                      ],
                    ),
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
                          ? FileImage(_newAvatar!) as ImageProvider
                          : (hasAvatar ? NetworkImage(currentAvatarUrl) as ImageProvider : null),
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
                          ? FileImage(_newAvatar!) as ImageProvider
                          : (widget.pet.profileImageUrl.isNotEmpty
                              ? NetworkImage(widget.pet.profileImageUrl) as ImageProvider
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
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
          SizedBox(
            width: 68,
            child: Text(
              'All',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
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
          SizedBox(
            width: 68,
            child: Text(
              pet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
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
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(
            width: 68,
            child: Text(
              'Add Pet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFFF8A65),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
        Text(
          label,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
