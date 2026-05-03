import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/pet_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../controllers/follow_controller.dart';
import '../utils/image_upload_helper.dart';
import '../utils/media_utils.dart';
import '../utils/supabase_config.dart';
import '../theme/app_theme.dart';
import 'main_layout.dart' show bottomNavSpaceFor;
import '../repositories/pet_repository.dart';
import '../controllers/chat_controller.dart';
import '../controllers/match_controller.dart';
import 'components/public_care_badges_row.dart';
import '../widgets/brand_logo.dart';

typedef VisitProfileArgs = ({String? petId, String? userId});

/// Loads a host user + all their pets (for `/pet/:id` and `/user/:id` visitor profile).
final visitProfileDataProvider = FutureProvider.family<
    Map<String, dynamic>, VisitProfileArgs>((ref, args) async {
  final petId = args.petId;
  final userIdArg = args.userId;

  String targetUserId;
  PetModel? initialPet;

  if (petId != null) {
    initialPet = await petRepository.fetchPetById(petId);
    if (initialPet == null) throw Exception('Pet not found');
    targetUserId = initialPet.userId;
  } else if (userIdArg != null) {
    targetUserId = userIdArg;
  } else {
    throw Exception('Must provide petId or userId');
  }

  final user = await ref.read(publicUserProvider(targetUserId).future);
  final allPets = await petRepository.fetchMyPets(targetUserId);

  return {
    'user': user,
    'pets': allPets,
    'initialPet': initialPet,
  };
});

class PetProfileScreen extends ConsumerStatefulWidget {
  const PetProfileScreen({super.key, this.visitPetId, this.visitUserId});

  final String? visitPetId;
  final String? visitUserId;

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen> {
  String? selectedId;
  String? postCategory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.visitPetId != null || widget.visitUserId != null) {
      return ref
          .watch(visitProfileDataProvider((
        petId: widget.visitPetId,
        userId: widget.visitUserId,
      )))
          .when(
        loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(leading: const BackButton()),
          body: Center(child: Text('Error: $e')),
        ),
        data: (d) => buildScaffoldCore(
            isVisitor: true, visitData: d, colorScheme: colorScheme),
      );
    }
    return buildScaffoldCore(
        isVisitor: false, visitData: null, colorScheme: colorScheme);
  }

  Widget buildScaffoldCore({
    required bool isVisitor,
    required ColorScheme colorScheme,
    Map<String, dynamic>? visitData,
  }) {
    if (!isVisitor) {
      ref.listen<String?>(profilePetNavigationProvider, (prev, next) {
        if (next != null) {
          setState(() => selectedId = next);
          ref.read(profilePetNavigationProvider.notifier).clear();
        }
      });
    }

    final authState = ref.watch(authProvider);
    final accountUser = authState.user;

    UserModel? visitHostUser;
    late final List<PetModel> profilePets;

    if (isVisitor) {
      visitHostUser = visitData!['user'] as UserModel;
      profilePets = visitData['pets'] as List<PetModel>;
      selectedId ??= (visitData['initialPet'] as PetModel?)?.id ?? 'owner';
    } else {
      final petState = ref.watch(petProvider);
      profilePets = petState.myPets;
      selectedId ??= 'owner';
    }

    final userName =
        (isVisitor ? visitHostUser?.name : accountUser?.name) ?? 'Pet Lover';
    final UserModel? ownerForHeader =
        isVisitor ? visitHostUser : accountUser;

    var isOwnerView = selectedId == 'owner';

    PetModel? selectedPet;
    if (!isOwnerView && profilePets.isNotEmpty) {
      selectedPet = profilePets.firstWhere(
        (p) => p.id == selectedId,
        orElse: () => profilePets.first,
      );
    }

    if (!isOwnerView && selectedPet == null) {
      selectedId = 'owner';
      isOwnerView = true;
    }

    final feedState = ref.watch(feedProvider);
    final postsUserId = isVisitor
        ? (visitHostUser?.id ?? '')
        : (accountUser?.id ?? '');
    final allPetPosts = isOwnerView
        ? feedState.posts
            .where((post) => post.pet.userId == postsUserId)
            .toList()
        : feedState.posts
            .where((post) => post.pet.id == selectedPet?.id)
            .toList();

    final displayedPosts = (postCategory == null || isOwnerView)
        ? allPetPosts
        : allPetPosts
            .where((p) =>
                p.caption.toLowerCase().contains(postCategory!.toLowerCase()))
            .toList();

    final statsUserId = postsUserId;
    final bottomSpace =
        isVisitor ? 32.0 : bottomNavSpaceFor(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          if (isVisitor) {
            ref.invalidate(visitProfileDataProvider((
              petId: widget.visitPetId,
              userId: widget.visitUserId,
            )));
          } else {
            await ref.read(petProvider.notifier).reload();
          }
          await ref.read(feedProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Hero SliverAppBar ────────────────────────────────────
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 44,
              leading: isVisitor
                  ? Padding(
                      padding: const EdgeInsets.all(6),
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer.withAlpha(200),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : null,
              actions: [
                if (!isVisitor)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => context.push('/settings'),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer.withAlpha(200),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.settings_rounded,
                            color: colorScheme.onSurface, size: 18),
                      ),
                    ),
                  ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
            ),

            // ── Profile Header ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + Stats row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildFloatingAvatar(
                          colorScheme: colorScheme,
                          isOwnerView: isOwnerView,
                          ownerForHeader: ownerForHeader,
                          selectedPet: selectedPet,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StatColumn(
                                label: 'posts',
                                value: '${displayedPosts.length}',
                              ),
                              if (isOwnerView) ...[
                                ref
                                    .watch(ownerFollowerCountProvider(
                                        statsUserId))
                                    .when(
                                      data: (c) => StatColumn(
                                          label: 'followers', value: '$c'),
                                      loading: () => const StatColumn(
                                          label: 'followers', value: '···'),
                                      error: (_, _) => const StatColumn(
                                          label: 'followers', value: '0'),
                                    ),
                                ref
                                    .watch(
                                        followingCountProvider(statsUserId))
                                    .when(
                                      data: (c) => StatColumn(
                                          label: 'following', value: '$c'),
                                      loading: () => const StatColumn(
                                          label: 'following', value: '···'),
                                      error: (_, _) => const StatColumn(
                                          label: 'following', value: '0'),
                                    ),
                              ] else if (selectedPet != null) ...[
                                // Tappable follower count → opens followers list
                                GestureDetector(
                                  onTap: () => context.push(
                                      '/pet/${selectedPet!.id}/followers'),
                                  child: ref
                                      .watch(petFollowerCountProvider(
                                          selectedPet.id))
                                      .when(
                                        data: (c) => StatColumn(
                                            label: 'followers',
                                            value: '$c',
                                            tappable: !isVisitor),
                                        loading: () => const StatColumn(
                                            label: 'followers', value: '···'),
                                        error: (_, _) => const StatColumn(
                                            label: 'followers', value: '0'),
                                      ),
                                ),
                                StatColumn(
                                  label: 'pets',
                                  value: '${profilePets.length}',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Pet/owner name + verified badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isOwnerView
                                ? userName
                                : (selectedPet?.name ?? ''),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isOwnerView &&
                            (selectedPet?.isVerified ?? false))
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.verified_rounded,
                              size: 18,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Info row: breed/location/email
                    if (!isVisitor &&
                        isOwnerView &&
                        accountUser?.email != null)
                      InfoChip(
                        icon: Icons.alternate_email_rounded,
                        text:
                            '${accountUser!.email}${accountUser.location?.isNotEmpty == true ? "  ·  ${accountUser.location}" : ""}',
                        colorScheme: colorScheme,
                      ),
                    if (isVisitor &&
                        isOwnerView &&
                        (visitHostUser?.location?.isNotEmpty ?? false))
                      InfoChip(
                        icon: Icons.location_on_outlined,
                        text: visitHostUser!.location!,
                        colorScheme: colorScheme,
                      ),
                    if (!isOwnerView && selectedPet != null)
                      InfoChip(
                        useBrandIcon: true,
                        text:
                            '${selectedPet.breed}  ·  ${selectedPet.animalType}',
                        colorScheme: colorScheme,
                      ),
                    const SizedBox(height: 8),

                    // Bio
                    Text(
                      isOwnerView
                          ? ((isVisitor
                                      ? visitHostUser?.bio
                                      : accountUser?.bio)
                                  ?.isNotEmpty ==
                              true
                              ? (isVisitor
                                  ? visitHostUser!.bio!
                                  : accountUser!.bio!)
                              : (isVisitor
                                  ? 'No bio yet.'
                                  : 'Tap "Edit profile" to add a bio.'))
                          : (selectedPet?.bio.isNotEmpty == true
                              ? selectedPet!.bio
                              : 'No bio yet.'),
                      style: GoogleFonts.dmSans(
                        color: (isOwnerView &&
                                    (isVisitor
                                        ? (visitHostUser?.bio?.isEmpty ??
                                            true)
                                        : (accountUser?.bio?.isEmpty ??
                                            true))) ||
                                (!isOwnerView &&
                                    selectedPet?.bio.isEmpty == true)
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                        fontSize: 14,
                        height: 1.5,
                        fontStyle: (isOwnerView &&
                                !isVisitor &&
                                (accountUser?.bio?.isEmpty ?? true))
                            ? FontStyle.italic
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Action buttons ───────────────────────────────
                    if (isVisitor)
                      ProfileVisitorActionRow(
                        isOwnerView: isOwnerView,
                        visitHostUser: visitHostUser!,
                        selectedPet: selectedPet,
                        onMessage: () => onVisitorMessage(
                          isOwnerView: isOwnerView,
                          selectedPet: selectedPet,
                          profilePets: profilePets,
                        ),
                        onShare: () {
                          final link = isOwnerView
                              ? 'https://petfolio.app/user/${visitHostUser!.id}'
                              : 'https://petfolio.app/pet/${selectedPet?.id ?? ''}';
                          final name = isOwnerView
                              ? userName
                              : (selectedPet?.name ?? '');
                          showProfileShareSheet(context, link, name);
                        },
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon:
                                  const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit Profile'),
                              onPressed: () {
                                if (isOwnerView) {
                                  showEditOwnerSheet(context, accountUser);
                                } else if (selectedPet != null) {
                                  showEditPetSheet(context, selectedPet);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    colorScheme.surfaceContainer,
                                foregroundColor: colorScheme.onSurface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.ios_share_rounded,
                                  size: 16),
                              label: const Text('Share'),
                              onPressed: () {
                                final link = isOwnerView
                                    ? 'https://petfolio.app/user/${accountUser?.id ?? ''}'
                                    : 'https://petfolio.app/pet/${selectedPet?.id ?? ''}';
                                final name = isOwnerView
                                    ? userName
                                    : (selectedPet?.name ?? '');
                                showProfileShareSheet(context, link, name);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    colorScheme.surfaceContainer,
                                foregroundColor: colorScheme.onSurface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                    // ── Match Request CTA (visitor + pet view only) ──
                    if (isVisitor && !isOwnerView && selectedPet != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.favorite_rounded, size: 18),
                          label: Text(
                            'Send Match Request',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () async {
                            final success = await ref
                                .read(matchProvider.notifier)
                                .sendLikeRequest(selectedPet!.id);
                            if (!mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Request sent to ${selectedPet.name}!'),
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryAccent,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // ── Care badges (own profile only) ───────────────
                    if (isOwnerView && statsUserId.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      PublicCareBadgesRow(userId: statsUserId),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Pet selector chips ────────────────────────────────────
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => selectedId = 'owner'),
                      child: OwnerCarouselAvatar(
                        user: ownerForHeader,
                        isSelected: isOwnerView,
                      ),
                    ),
                    for (final pet in profilePets)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => selectedId = pet.id),
                        child: PetCarouselAvatar(
                          pet: pet,
                          isSelected: pet.id == selectedId,
                        ),
                      ),
                    if (!isVisitor)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.push('/add_pet'),
                        child: const AddPetAvatar(),
                      ),
                  ],
                ),
              ),
            ),

            // ── Post category filter chips ────────────────────────────
            if (!isOwnerView && selectedPet != null)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      for (final cat in [
                        null,
                        'Playtime',
                        'Nap',
                        'Outdoor',
                        'Food'
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => postCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: postCategory == cat
                                    ? colorScheme.secondary
                                    : colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                cat ?? 'All Posts',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: postCategory == cat
                                      ? colorScheme.onSecondary
                                      : colorScheme.onSecondaryContainer,
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

            // ── Posts grid ────────────────────────────────────────────
            if (profilePets.isEmpty && isOwnerView && !isVisitor)
              SliverToBoxAdapter(
                child: EmptyPetsCta(
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
                        Icon(Icons.camera_alt_outlined,
                            size: 48,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'No posts yet',
                          style: GoogleFonts.dmSans(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOwnerView
                              ? 'Create a post to see it here.'
                              : (isVisitor
                                  ? 'No posts from ${selectedPet?.name ?? 'this pet'} yet.'
                                  : 'Create a post as ${selectedPet?.name ?? 'this pet'}.'),
                          style: GoogleFonts.dmSans(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13),
                        ),
                        if (!isVisitor &&
                            !isOwnerView &&
                            selectedPet != null) ...[
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => context.push(
                                '/create_post?petId=${selectedPet!.id}'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add_a_photo_outlined,
                                      size: 16, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Create Post',
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
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
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = displayedPosts[index];
                      return GestureDetector(
                        onTap: () => context.push('/post/${post.id}'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (isVideoMedia(post.mediaUrl))
                                Container(
                                  color: colorScheme.scrim.withAlpha(51),
                                  child: Center(
                                    child: Icon(
                                      Icons.play_circle_fill_rounded,
                                      color: AppTheme.primaryAccent,
                                      size: 42,
                                    ),
                                  ),
                                )
                              else
                                CachedNetworkImage(
                                  imageUrl: post.mediaUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: colorScheme.surfaceContainer,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: colorScheme.surfaceContainer,
                                    child: Icon(Icons.image_outlined,
                                        color: colorScheme.onSurfaceVariant),
                                  ),
                                ),
                              if (isVideoMedia(post.mediaUrl))
                                const Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Icon(
                                    Icons.videocam_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              if (isOwnerView)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
                                    backgroundImage: post
                                            .pet.profileImageUrl.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            post.pet.profileImageUrl)
                                        : null,
                                    child: post.pet.profileImageUrl.isEmpty
                                        ? Text(
                                            post.pet.name.isNotEmpty
                                                ? post.pet.name[0]
                                                : '?',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
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

            SliverToBoxAdapter(child: SizedBox(height: bottomSpace)),
          ],
        ),
      ),
      floatingActionButton: !isVisitor && !isOwnerView && selectedPet != null
          ? Padding(
              padding:
                  EdgeInsets.only(bottom: bottomNavSpaceFor(context)),
              child: FloatingActionButton(
                heroTag: 'profile_fab',
                onPressed: () =>
                    context.push('/create_post?petId=${selectedPet!.id}'),
                backgroundColor: AppTheme.primaryAccent,
                child: const Icon(Icons.add_a_photo_outlined,
                    color: Colors.white),
              ),
            )
          : null,
    );
  }

  /// Premium circular avatar with warm amber ring.
  Widget buildFloatingAvatar({
    required ColorScheme colorScheme,
    required bool isOwnerView,
    required UserModel? ownerForHeader,
    required PetModel? selectedPet,
  }) {
    final String? imageUrl = isOwnerView
        ? ownerForHeader?.profileImageUrl
        : selectedPet?.profileImageUrl;
    final bool hasImage =
        imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryAccent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
        ),
        child: CircleAvatar(
          radius: 38,
          backgroundColor: isOwnerView
              ? colorScheme.tertiary.withAlpha(26)
              : colorScheme.surfaceContainer,
          backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
              ? CachedNetworkImageProvider(imageUrl)
              : null,
          child: !hasImage
              ? (isOwnerView
                  ? Text(
                      ownerForHeader?.initials ?? '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.tertiary,
                      ),
                    )
                  : Icon(
                      Icons.pets_rounded,
                      size: 30,
                      color: colorScheme.onSurfaceVariant,
                    ))
              : null,
        ),
      ),
    );
  }

  void showProfileShareSheet(
      BuildContext context, String shareLink, String name) {
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
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
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: shareLink));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: colorScheme.onPrimary, size: 16),
                          const SizedBox(width: 8),
                          const Text('Link copied to clipboard!'),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context)
                          .snackBarTheme
                          .backgroundColor,
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
                  child: Icon(Icons.chat_bubble_outline,
                      color: colorScheme.secondary),
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
                  child:
                      Icon(Icons.qr_code, color: colorScheme.tertiary),
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
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            shareLink,
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: shareLink));
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

  void showEditOwnerSheet(BuildContext context, UserModel? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditOwnerSheet(user: user),
    );
  }

  void showEditPetSheet(BuildContext context, PetModel pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditPetSheet(pet: pet),
    );
  }

  void showLogoutConfirmation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> onVisitorMessage({
    required bool isOwnerView,
    required PetModel? selectedPet,
    required List<PetModel> profilePets,
  }) async {
    final myPet = ref.read(activePetProvider);
    if (myPet == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an active pet in the app to start a chat.'),
        ),
      );
      return;
    }

    late final String otherPetId;
    if (isOwnerView) {
      if (profilePets.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This profile has no pets to message yet.'),
          ),
        );
        return;
      }
      otherPetId = profilePets.first.id;
    } else {
      if (selectedPet == null) return;
      otherPetId = selectedPet.id;
    }

    if (otherPetId == myPet.id) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot message your own pet.'),
        ),
      );
      return;
    }

    final threadId =
        await ref.read(chatProvider.notifier).createOrGetThread(otherPetId);
    if (!mounted) return;
    if (threadId != null) {
      context.push('/chat/$threadId');
    } else {
      final err = ref.read(chatProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Could not open chat'),
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────
// Visitor Action Row — Follow | Message | Share
// ─────────────────────────────────────────────────────────
class ProfileVisitorActionRow extends ConsumerWidget {
  const ProfileVisitorActionRow({super.key, 
    required this.isOwnerView,
    required this.visitHostUser,
    required this.selectedPet,
    required this.onMessage,
    required this.onShare,
  });

  final bool isOwnerView;
  final UserModel visitHostUser;
  final PetModel? selectedPet;
  final VoidCallback onMessage;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOwnerView && selectedPet == null) {
      return const SizedBox.shrink();
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: isOwnerView
              ? _visitFollowForOwner(context, ref, visitHostUser.id)
              : _visitFollowForPet(context, ref, selectedPet!.id),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Message',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            onPressed: onMessage,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
              minimumSize: const Size(0, 44),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: 'Share profile',
          child: InkWell(
            onTap: onShare,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outline),
              ),
              child: Icon(Icons.ios_share_rounded,
                  size: 20, color: colorScheme.onSurface),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _visitFollowForOwner(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
  ) {
    return ref.watch(isFollowingOwnerProvider(ownerId)).when(
      loading: () => const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => ElevatedButton.icon(
        icon: const Icon(Icons.person_add_rounded, size: 15),
        label: const Text('Follow'),
        onPressed: () {
          ref
              .read(followControllerProvider.notifier)
              .toggleFollowOwner(ownerId);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      data: (follows) {
        final colorScheme = Theme.of(context).colorScheme;
        return ElevatedButton.icon(
          icon: Icon(
            follows
                ? Icons.person_remove_outlined
                : Icons.person_add_rounded,
            size: 15,
          ),
          label: Text(
            follows ? 'Unfollow' : 'Follow',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                follows ? colorScheme.surfaceContainer : colorScheme.primary,
            foregroundColor:
                follows ? colorScheme.onSurface : colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
          ),
          onPressed: () {
            ref
                .read(followControllerProvider.notifier)
                .toggleFollowOwner(ownerId);
          },
        );
      },
    );
  }

  static Widget _visitFollowForPet(
    BuildContext context,
    WidgetRef ref,
    String petId,
  ) {
    return ref.watch(isFollowingPetProvider(petId)).when(
      loading: () => const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => ElevatedButton.icon(
        icon: const Icon(Icons.person_add_rounded, size: 15),
        label: const Text('Follow'),
        onPressed: () {
          ref
              .read(followControllerProvider.notifier)
              .toggleFollowPet(petId);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      data: (follows) {
        final colorScheme = Theme.of(context).colorScheme;
        return ElevatedButton.icon(
          icon: Icon(
            follows
                ? Icons.person_remove_outlined
                : Icons.person_add_rounded,
            size: 15,
          ),
          label: Text(
            follows ? 'Unfollow' : 'Follow',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                follows ? colorScheme.surfaceContainer : colorScheme.primary,
            foregroundColor:
                follows ? colorScheme.onSurface : colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
          ),
          onPressed: () {
            ref
                .read(followControllerProvider.notifier)
                .toggleFollowPet(petId);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// Edit Owner Profile Bottom Sheet
// ─────────────────────────────────────────────────────────
class EditOwnerSheet extends ConsumerStatefulWidget {
  final UserModel user;

  const EditOwnerSheet({super.key, required this.user});

  @override
  ConsumerState<EditOwnerSheet> createState() => EditOwnerSheetState();
}

class EditOwnerSheetState extends ConsumerState<EditOwnerSheet> {
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
    _locationController =
        TextEditingController(text: widget.user.location ?? '');
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
            final colorScheme = Theme.of(context).colorScheme;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Avatar upload failed: ${reason.length > 100 ? '${reason.substring(0, 100)}…' : reason}',
                ),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
      final success =
          await ref.read(authProvider.notifier).updateProfile(fields);

      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: colorScheme.onPrimary, size: 18),
                  const SizedBox(width: 8),
                  const Text('Profile updated!'),
                ],
              ),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else {
          final authError = ref.read(authProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: ${authError ?? 'Unknown error'}'),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
    final colorScheme = Theme.of(context).colorScheme;
    final currentAvatarUrl = widget.user.profileImageUrl;
    final hasAvatar = currentAvatarUrl != null && currentAvatarUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: colorScheme.outlineVariant,
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
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.tertiary.withAlpha(26),
                      backgroundImage: _newAvatar != null
                          ? FileImage(_newAvatar!) as ImageProvider
                          : (hasAvatar
                              ? CachedNetworkImageProvider(currentAvatarUrl)
                                  as ImageProvider
                              : null),
                      child: (_newAvatar == null && !hasAvatar)
                          ? Text(
                              widget.user.initials,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.tertiary,
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
                          color: colorScheme.tertiary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colorScheme.onTertiary, width: 2),
                        ),
                        child: Icon(Icons.camera_alt,
                            size: 16, color: colorScheme.onTertiary),
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
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            SheetFieldLabel(
                icon: Icons.badge_outlined,
                label: 'Display Name',
                colorScheme: colorScheme),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _sheetInputDecoration('Your name', colorScheme),
            ),
            const SizedBox(height: 20),
            SheetFieldLabel(
                icon: Icons.description_outlined,
                label: 'Bio',
                colorScheme: colorScheme),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: _sheetInputDecoration(
                  'Tell others about yourself...', colorScheme),
            ),
            const SizedBox(height: 20),
            SheetFieldLabel(
                icon: Icons.location_on_outlined,
                label: 'Location',
                colorScheme: colorScheme),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              textCapitalization: TextCapitalization.words,
              decoration:
                  _sheetInputDecoration('e.g. New York, NY', colorScheme),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onTertiary,
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

  InputDecoration _sheetInputDecoration(
      String hint, ColorScheme colorScheme) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.tertiary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Edit Pet Bottom Sheet
// ─────────────────────────────────────────────────────────
class EditPetSheet extends ConsumerStatefulWidget {
  final PetModel pet;

  const EditPetSheet({super.key, required this.pet});

  @override
  ConsumerState<EditPetSheet> createState() => EditPetSheetState();
}

class EditPetSheetState extends ConsumerState<EditPetSheet> {
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
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
                color: colorScheme.outlineVariant,
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
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library_rounded,
                    color: colorScheme.tertiary),
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
                  color: colorScheme.secondary.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt_rounded,
                    color: colorScheme.secondary),
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
          final path =
              '${widget.pet.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
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
            final errorColorScheme = Theme.of(context).colorScheme;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Photo upload failed: ${reason.length > 100 ? '${reason.substring(0, 100)}…' : reason}',
                ),
                backgroundColor: errorColorScheme.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }

      if (fields.isEmpty) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final success = await ref
          .read(petProvider.notifier)
          .updatePet(widget.pet.id, fields);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          final successColorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: successColorScheme.onPrimary, size: 18),
                  const SizedBox(width: 8),
                  const Text('Profile updated!'),
                ],
              ),
              backgroundColor: successColorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else {
          final petError = ref.read(petProvider).error;
          final failureColorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Update failed: ${petError ?? 'Unknown error'}'),
              backgroundColor: failureColorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: colorScheme.outlineVariant,
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
                      backgroundColor: colorScheme.surfaceContainerLowest,
                      backgroundImage: _newAvatar != null
                          ? FileImage(_newAvatar!) as ImageProvider
                          : (widget.pet.profileImageUrl.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  widget.pet.profileImageUrl)
                                  as ImageProvider
                              : null),
                      child: (_newAvatar == null &&
                              widget.pet.profileImageUrl.isEmpty)
                          ? Icon(Icons.pets,
                              size: 32,
                              color: colorScheme.onSurfaceVariant)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colorScheme.onTertiary, width: 2),
                        ),
                        child: Icon(Icons.camera_alt,
                            size: 16, color: colorScheme.onTertiary),
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
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Name',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Breed',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _breedController,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Bio',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
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
                  backgroundColor: colorScheme.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onTertiary,
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

class SheetFieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const SheetFieldLabel({super.key, 
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.tertiary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Small icon + text chip used for location/breed/email under the name.
class InfoChip extends StatelessWidget {
  final IconData? icon;
  final bool useBrandIcon;
  final String text;
  final ColorScheme colorScheme;

  const InfoChip({super.key, 
    this.icon,
    this.useBrandIcon = false,
    required this.text,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          useBrandIcon
              ? BrandLogo(customSize: 13, color: colorScheme.onSurfaceVariant)
              : Icon(icon!, size: 13, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyPetsCta extends StatelessWidget {
  final VoidCallback onAddPet;

  const EmptyPetsCta({super.key, required this.onAddPet});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  colorScheme.tertiary.withAlpha(51),
                  colorScheme.secondary.withAlpha(51),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child:
                BrandLogo(customSize: 48, color: colorScheme.tertiary),
          ),
          const SizedBox(height: 20),
          Text(
            'No Pets Yet!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first pet to start sharing photos,\nfinding matches, and connecting with others.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
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
              backgroundColor: colorScheme.tertiary,
              foregroundColor: colorScheme.onTertiary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

class OwnerCarouselAvatar extends StatelessWidget {
  final UserModel? user;
  final bool isSelected;

  const OwnerCarouselAvatar(
      {super.key, required this.user, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0, bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withAlpha(38)
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color:
                isSelected ? colorScheme.primary : colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: colorScheme.primary.withAlpha(51),
              backgroundImage:
                  hasImage
                      ? CachedNetworkImageProvider(user!.profileImageUrl!)
                      : null,
              child: !hasImage
                  ? Text(
                      user?.initials ?? '?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: colorScheme.primary),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              'All',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PetCarouselAvatar extends StatelessWidget {
  final PetModel pet;
  final bool isSelected;

  const PetCarouselAvatar(
      {super.key, required this.pet, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0, bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withAlpha(38)
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color:
                isSelected ? colorScheme.primary : colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: pet.profileImageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(pet.profileImageUrl)
                  : null,
              backgroundColor: colorScheme.surfaceContainer,
              child: pet.profileImageUrl.isEmpty
                  ? const BrandLogo(customSize: 14)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              pet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPetAvatar extends StatelessWidget {
  const AddPetAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0, bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: colorScheme.primary.withAlpha(128),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: colorScheme.primary.withAlpha(26),
              child: Icon(Icons.add_rounded,
                  color: colorScheme.primary, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'Add Pet',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool tappable;

  const StatColumn({
    super.key,
    required this.label,
    required this.value,
    this.tappable = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: colorScheme.onSurface,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (tappable) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
