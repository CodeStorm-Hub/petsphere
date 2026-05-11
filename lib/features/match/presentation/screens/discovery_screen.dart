import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/match_controller.dart';
import 'package:petfolio/core/theme/app_theme.dart';
import 'package:petfolio/core/utils/layout_utils.dart';
import 'package:petfolio/core/widgets/brand_logo.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Discovery Screen (tab host)
// ─────────────────────────────────────────────────────────────────────────────
class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petProvider);
    final myPets = petState.myPets;
    final activePetId = ref.watch(activePetProvider.select((p) => p?.id));
    final listedPets = myPets.where((p) => p.isBreedingListed).toList();
    final navSpace = bottomNavSpaceFor(context);
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Breeding Discovery'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Discover'),
              Tab(text: 'Nearby'),
              Tab(text: 'My Listings'),
            ],
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            dividerColor: Colors.transparent,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_outline),
              tooltip: 'Liked Pets',
              onPressed: () => context.push('/liked_pets'),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'New Listing',
              onPressed: () => showListPetSheet(context, ref),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            DiscoveryTab(
              hasActivePet: activePetId != null,
              isPetLoading: petState.isLoading,
            ),
            const NearbyTab(),
            MyListingsTab(listedPets: listedPets, navSpace: navSpace),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Listings Tab
// ─────────────────────────────────────────────────────────────────────────────
class MyListingsTab extends ConsumerWidget {
  const MyListingsTab({
    super.key,
    required this.listedPets,
    required this.navSpace,
  });
  final List<PetModel> listedPets;
  final double navSpace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () => ref.read(petProvider.notifier).reload(),
      child: listedPets.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: navSpace, top: 100),
              children: [
                PetfolioEmptyState(
                  icon: Icons.pets_outlined,
                  title: "You haven't listed any pets yet.",
                  message: 'Tap "New Listing" to add your pet to discovery.',
                  buttonText: 'Start Listing',
                  onButtonPressed: () => showListPetSheet(context, ref),
                ),
              ],
            )

          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + navSpace),
              itemCount: listedPets.length,
              itemBuilder: (context, index) {
                final pet = listedPets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: pet.profileImageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(pet.profileImageUrl)
                          : null,
                      child: pet.profileImageUrl.isEmpty
                          ? BrandLogo(
                              size: BrandLogoSize.small,
                              color: colorScheme.primary,
                            )
                          : null,
                    ),
                    title: Text(
                      pet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${pet.breed} • ${pet.animalType}'),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      onPressed: () async {
                        final success = await ref
                            .read(petProvider.notifier)
                            .toggleBreedingListing(pet.id, false);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${pet.name} removed from breeding listings.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Discover Tab  —  swipeable card stack
// ─────────────────────────────────────────────────────────────────────────────
class DiscoveryTab extends ConsumerStatefulWidget {

  const DiscoveryTab({
    super.key,
    required this.hasActivePet,
    required this.isPetLoading,
  });
  final bool hasActivePet;
  final bool isPetLoading;

  @override
  ConsumerState<DiscoveryTab> createState() => DiscoveryTabState();
}

class DiscoveryTabState extends ConsumerState<DiscoveryTab> {
  int currentIndex = 0;
  String? filterType; // null = For You, 'breed' = Same Breed, 'nearby' = Nearby
  final Set<String> dismissedPetIds = {};
  // Tracks pets whose discovery feeds are known to be empty after loading.
  final Set<String> allCaughtUpPetIds = {};

  final CardSwiperController _swiperController = CardSwiperController();

  static const _filterLabels = ['For You', 'Same Breed', 'Nearby'];
  // We use these locally for UI state; 'breed' and 'nearby' are special modes.
  static const _filterValues = [null, 'breed', 'nearby'];

  @override
  void initState() {
    super.initState();
    // Seed the discovery pet selector with the global active pet on first load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final activePetId = ref.read(petProvider).activePet?.id;
      if (ref.read(discoveryActivePetIdProvider) == null &&
          activePetId != null) {
        ref.read(discoveryActivePetIdProvider.notifier).select(activePetId);
      }
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final filteredPets = _applyFilter(ref.read(matchProvider).discoveryPets);
    if (previousIndex >= filteredPets.length) return false;
    final pet = filteredPets[previousIndex];
    final liked = direction == CardSwiperDirection.right;

    setState(() {
      dismissedPetIds.add(pet.id);
      if (currentIndex != null) {
        this.currentIndex = currentIndex;
      }
    });

    if (liked) {
      final discoveryPetId = ref.read(discoveryActivePetIdProvider);
      ref
          .read(matchProvider.notifier)
          .sendLikeRequest(pet.id, fromPetId: discoveryPetId)
          .then((success) {
        if (!mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Liked ${pet.name}! 🐾'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() => dismissedPetIds.remove(pet.id));
          final error = ref.read(matchProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Could not send like. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
    return true;
  }

  List<PetModel> _applyFilter(List<PetModel> allPets) {
    final visible = allPets
        .where((p) => !dismissedPetIds.contains(p.id))
        .toList();

    if (filterType == 'nearby') {
      return [...visible]
        ..sort((a, b) => _fakeDistanceMi(a).compareTo(_fakeDistanceMi(b)));
    }

    return visible;
  }

  void _clampIndex(List<PetModel> allPets) {
    final filtered = _applyFilter(allPets);
    if (filtered.isEmpty) {
      currentIndex = 0;
    } else if (currentIndex >= filtered.length) {
      currentIndex = filtered.length - 1;
    }
  }

  int _fakeDistanceMi(PetModel pet) => (pet.id.hashCode.abs() % 25) + 1;

  void _selectPet(PetModel pet) {
    ref.read(discoveryActivePetIdProvider.notifier).select(pet.id);
    setState(() {
      dismissedPetIds.clear();
      currentIndex = 0;
      if (filterType != null &&
          filterType != 'nearby' &&
          filterType != pet.animalType) {
        filterType = null;
      }
    });
    ref.read(matchProvider.notifier).load(pet.id);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Sync dismissed IDs when the discovery list reloads and track caught-up.
    ref.listen<MatchState>(matchProvider, (prev, next) {
      if (!mounted) return;
      final petsChanged = prev?.discoveryPets != next.discoveryPets;
      // A full load cycle just completed (isLoading transitioned false→false
      // via true, i.e. prev was loading and now it's done).
      final loadCycleFinished = prev?.isLoading == true && !next.isLoading;
      final loadFinishedEmpty = loadCycleFinished && next.discoveryPets.isEmpty;

      if (!petsChanged && !loadFinishedEmpty) return;

      final currentIds = next.discoveryPets.map((p) => p.id).toSet();
      setState(() {
        if (petsChanged) {
          // Only purge dismissed IDs during a real load cycle (when
          // isLoading transitioned). Optimistic updates from sendLikeRequest
          // set petsChanged=true but keep isLoading=false throughout, so we
          // skip the purge there to avoid re-showing the just-dismissed pet
          // if a concurrent network fetch brings it back momentarily.
          if (loadCycleFinished) {
            dismissedPetIds.removeWhere((id) => !currentIds.contains(id));
          }
          _clampIndex(next.discoveryPets);
        }
        if (loadFinishedEmpty) {
          final selId =
              ref.read(discoveryActivePetIdProvider) ??
              ref.read(petProvider).activePet?.id;
          if (selId != null) allCaughtUpPetIds.add(selId);
        }
      });
    });

    final matchState = ref.watch(matchProvider);
    final filteredPets = _applyFilter(matchState.discoveryPets);
    final hasPets = filteredPets.isNotEmpty;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;
    final navSpace = isTablet ? 24.0 : bottomNavSpaceFor(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isPetLoading || matchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!widget.hasActivePet) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24, 96, 24, 24 + navSpace),
        children: [
          PetfolioEmptyState(
            icon: Icons.pets_outlined,
            title: 'No Active Pet',
            message: 'Add a pet to start discovering breeding matches.',
            buttonText: 'Add Pet',
            onButtonPressed: () => context.push('/add_pet'),
          ),
        ],
      );
    }

    if (matchState.error != null && !hasPets) {
      return RefreshIndicator(
        onRefresh: () => ref.read(matchProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 96, 24, 24 + navSpace),
          children: [
            PetfolioEmptyState(
              icon: Icons.error_outline,
              title: 'Something went wrong',
              message: matchState.error!,
              buttonText: 'Try Again',
              onButtonPressed: () => ref.read(matchProvider.notifier).refresh(),
            ),
          ],
        ),
      );
    }

    final myPets = ref.watch(petProvider).myPets;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            // ── Pet selector (only when user has multiple pets) ──────────
            if (myPets.length > 1)
              PetSelectorBar(
                allCaughtUpPetIds: allCaughtUpPetIds,
                onPetSelected: _selectPet,
              ),

            // ── Filter chips ────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: List.generate(_filterLabels.length, (i) {
                  final value = _filterValues[i];
                  // Check selection: 'For You' is null/null, 'Same Breed' is 'breed' mode, 'Nearby' is 'nearby' mode
                  final isSelected = filterType == value;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        final selId =
                            ref.read(discoveryActivePetIdProvider) ??
                            ref.read(petProvider).activePet?.id;
                        final myPets = ref.read(petProvider).myPets;
                        PetModel? selPet;
                        if (selId != null) {
                          selPet = myPets.cast<PetModel?>().firstWhere(
                            (p) => p?.id == selId,
                            orElse: () => null,
                          );
                        }

                        setState(() {
                          filterType = value;
                          currentIndex = 0;
                        });

                        // Sync with controller
                        if (value == 'breed') {
                          if (selPet != null) {
                            ref
                                .read(matchProvider.notifier)
                                .setFilterBreed(selPet.breed);
                          }
                        } else {
                          // Reset breed filter for 'For You' and 'Nearby'
                          ref.read(matchProvider.notifier).setFilterBreed(null);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _filterLabels[i],
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Card stack or empty state ────────────────────────────────
            Expanded(
              child: !hasPets
                  ? RefreshIndicator(
                      onRefresh: () => ref.read(matchProvider.notifier).refresh(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(24, 96, 24, 24 + navSpace),
                        children: const [
                          PetfolioEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'All caught up!',
                            message: 'No more pets available. Check back soon!',
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final sw = constraints.maxWidth;
                        // Responsive button sizes
                        final nopeSize = (sw * 0.158).clamp(52.0, 70.0);
                        final infoSize = (sw * 0.138).clamp(44.0, 60.0);
                        final likeSize = (sw * 0.198).clamp(64.0, 84.0);
                        final hPad = (sw * 0.048).clamp(12.0, 24.0);
                        final btnGap = sw * 0.045;

                        return Padding(
                          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, navSpace),
                          child: Column(
                            children: [
                              Expanded(
                                child: CardSwiper(
                                  controller: _swiperController,
                                  cardsCount: filteredPets.length,
                                  onSwipe: _onSwipe,
                                  numberOfCardsDisplayed: filteredPets.length > 1 ? 2 : 1,
                                  isLoop: false,
                                  padding: EdgeInsets.zero,
                                  cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                                    return PetCard(
                                      pet: filteredPets[index],
                                      isBackground: false,
                                      dragX: percentThresholdX.toDouble(),
                                      followerCount: matchState.discoveryFollowerCounts[filteredPets[index].id],
                                      onTap: () => context.push('/pet/${filteredPets[index].id}'),
                                    );
                                  },
                                ),
                              ),

                              // ── Action buttons ────────────────────────
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Nope
                                    ActionButton(
                                      key: const ValueKey('discovery_nope_button'),
                                      size: nopeSize,
                                      label: 'Nope',
                                      color: colorScheme.surface,
                                      borderColor: colorScheme.outlineVariant,
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: nopeSize * 0.44,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      onTap: () => _swiperController.swipe(CardSwiperDirection.left),
                                    ),
                                    SizedBox(width: btnGap),
                                    // Prominent View / Star
                                    ActionButton(
                                      key: const ValueKey('discovery_view_profile_button'),
                                      size: infoSize,
                                      label: 'View Profile',
                                      color: colorScheme.surface,
                                      borderColor: const Color(
                                        0xFF4A7DF7,
                                      ).withValues(alpha: 0.3),
                                      shadowColor: const Color(
                                        0xFF4A7DF7,
                                      ).withValues(alpha: 0.2),
                                      child: const Icon(
                                        Icons.star_rounded,
                                        size: 32,
                                        color: Color(0xFF4A7DF7),
                                      ),
                                      onTap: () => context.push(
                                        '/pet/${filteredPets[currentIndex].id}',
                                      ),
                                    ),
                                    SizedBox(width: btnGap),
                                    // Like
                                    ActionButton(
                                      key: const ValueKey('discovery_like_button'),
                                      size: likeSize,
                                      label: 'Like',
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.primary,
                                          colorScheme.primary.withValues(
                                            alpha: 0.8,
                                          ),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shadowColor: colorScheme.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      child: Icon(
                                        Icons.favorite_rounded,
                                        size: likeSize * 0.44,
                                        color: colorScheme.onPrimary,
                                      ),
                                      onTap: () => _swiperController.swipe(CardSwiperDirection.right),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );

  }
}

class PetCard extends StatelessWidget {

  const PetCard({
    super.key,
    required this.pet,
    required this.isBackground,
    required this.dragX,
    this.onTap,
    this.followerCount,
  });
  final PetModel pet;
  final bool isBackground;
  final double dragX;
  final VoidCallback? onTap;

  /// When non-null (e.g. from batched discovery query), shown on-card.
  final int? followerCount;

  String _petVibe() {
    final vibes = [
      'Cuddle Bug',
      'Adventurer',
      'Quiet Observer',
      'Social Butterfly',
      'Playful Spirit',
      'Gentle Soul',
      'Energy King',
      'Smarty Pants',
    ];
    return vibes[pet.id.hashCode.abs() % vibes.length];
  }

  IconData _vibeIcon(String vibe) {
    switch (vibe) {
      case 'Cuddle Bug':
        return Icons.favorite_rounded;
      case 'Adventurer':
        return Icons.explore_rounded;
      case 'Quiet Observer':
        return Icons.visibility_rounded;
      case 'Social Butterfly':
        return Icons.groups_rounded;
      case 'Playful Spirit':
        return Icons.auto_awesome_rounded;
      case 'Gentle Soul':
        return Icons.spa_rounded;
      case 'Energy King':
        return Icons.bolt_rounded;
      case 'Smarty Pants':
        return Icons.psychology_rounded;
      default:
        return Icons.pets_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final distanceMi = (pet.id.hashCode.abs() % 25) + 1;
    final vibe = _petVibe();
    final likeOpacity = isBackground
        ? 0.0
        : (dragX / 100).clamp(0.0, 1.0).toDouble();
    final nopeOpacity = isBackground
        ? 0.0
        : (-dragX / 100).clamp(0.0, 1.0).toDouble();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isBackground ? null : onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shadows = Theme.of(context).extension<PetFolioShadows>()!;
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(38),
              boxShadow: isBackground ? [] : shadows.card,
              border: Border.all(
                color: colorScheme.outline.withValues(
                  alpha: isDark ? 0.1 : 0.25,
                ),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Full Photo ───────────────────────────────────────────
                pet.profileImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: pet.profileImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _imageFallback(colorScheme),
                      )
                    : _imageFallback(colorScheme),

                // ── Immersive Gradient Overlay ───────────────────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 0.8, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Top Badges (Glassy) ──────────────────────────────────
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _GlassBadge(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$distanceMi mi',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (followerCount != null && followerCount! >= 0) ...[
                            _GlassBadge(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.group_rounded,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    followerCount!.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (pet.isVerified)
                            const _GlassBadge(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 18,
                                color: Color(0xFF4A7DF7),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Swipe Decision Overlays ──────────────────────────────
                if (!isBackground) ...[
                  Positioned(
                    top: 100,
                    right: 40,
                    child: Opacity(
                      opacity: likeOpacity,
                      child: Transform.rotate(
                        angle: 0.12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.greenAccent,
                              width: 3.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black38,
                          ),
                          child: const Text(
                            'LOVE',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 40,
                    child: Opacity(
                      opacity: nopeOpacity,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.redAccent,
                              width: 3.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black38,
                          ),
                          child: const Text(
                            'NOPE',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // ── Bottom Info Panel ─────────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Personality Vibe Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _vibeIcon(vibe),
                                size: 14,
                                color: colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                vibe.toUpperCase(),
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Name and Age
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                pet.name,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '${pet.age}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Breed and Type
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4A7DF7),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${pet.breed} • ${pet.animalType}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        if (pet.bio.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            pet.bio,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _imageFallback(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: BrandLogo(
          customSize: 80,
          color: colorScheme.primary.withAlpha(100),
        ),
      ),
    );
  }
}

// Nearby Tab
// ─────────────────────────────────────────────────────────────────────────────
class NearbyTab extends ConsumerWidget {
  const NearbyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchProvider);
    final navSpace = bottomNavSpaceFor(context);

    if (matchState.isLoading && matchState.discoveryPets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final sorted = [...matchState.discoveryPets]
      ..sort((a, b) => _distanceMi(a).compareTo(_distanceMi(b)));

    return RefreshIndicator(
      onRefresh: () => ref.read(matchProvider.notifier).refresh(),
      child: sorted.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: navSpace),
              children: [
                const SizedBox(height: 120),
                PetfolioEmptyState(
                  icon: Icons.location_off_outlined,
                  title: 'No Nearby Pets',
                  message: 'No pets found in your area. Try refreshing or adjusting your search.',
                  buttonText: 'Refresh',
                  onButtonPressed: () => ref.read(matchProvider.notifier).refresh(),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + navSpace),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final pet = sorted[index];
                final dist = _distanceMi(pet);
                return _NearbyPetTile(
                  pet: pet,
                  distanceMi: dist,
                  followerCount: matchState.discoveryFollowerCounts[pet.id],
                );
              },
            ),
    );
  }

  int _distanceMi(PetModel pet) => (pet.id.hashCode.abs() % 25) + 1;
}

class _NearbyPetTile extends StatelessWidget {

  const _NearbyPetTile({
    required this.pet,
    required this.distanceMi,
    this.followerCount,
  });
  final PetModel pet;
  final int distanceMi;
  final int? followerCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shadows = Theme.of(context).extension<PetFolioShadows>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/pet/${pet.id}'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: shadows.card,
          ),
          child: Row(
            children: [
              // Image container
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  image: pet.profileImageUrl.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            pet.profileImageUrl,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: pet.profileImageUrl.isEmpty
                    ? Center(
                        child: BrandLogo(
                          size: BrandLogoSize.small,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            pet.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (pet.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: Color(0xFF4A7DF7),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.breed} • ${pet.age} yrs',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$distanceMi mi away',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (followerCount != null && followerCount! >= 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.group_rounded,
                                  size: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  followerCount!.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Button
// ─────────────────────────────────────────────────────────────────────────────
class ActionButton extends StatelessWidget {

  const ActionButton({
    super.key,
    required this.size,
    required this.label,
    required this.child,
    required this.onTap,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.gradient,
  });
  final double size;
  final String label;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final LinearGradient? gradient;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: gradient == null ? color : null,
                gradient: gradient,
                shape: BoxShape.circle,
                border: borderColor != null
                    ? Border.all(color: borderColor!, width: 2.0)
                    : null,
                boxShadow: shadowColor != null
                    ? [
                        BoxShadow(
                          color: shadowColor!.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pet selector bar — horizontal chip row for choosing discovery pet
// ─────────────────────────────────────────────────────────────────────────────

/// Renders a horizontal scrollable row of pet chips.
/// Hidden when the user has only one pet.
class PetSelectorBar extends ConsumerWidget {

  const PetSelectorBar({
    super.key,
    required this.allCaughtUpPetIds,
    required this.onPetSelected,
  });
  final Set<String> allCaughtUpPetIds;
  final ValueChanged<PetModel> onPetSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPets = ref.watch(petProvider).myPets;
    if (myPets.length <= 1) return const SizedBox.shrink();

    final selectedId =
        ref.watch(discoveryActivePetIdProvider) ??
        ref.watch(petProvider).activePet?.id;

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: myPets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final pet = myPets[index];
          return _PetSelectorChip(
            pet: pet,
            isSelected: pet.id == selectedId,
            isCaughtUp: allCaughtUpPetIds.contains(pet.id),
            onTap: () => onPetSelected(pet),
          );
        },
      ),
    );
  }
}

class _PetSelectorChip extends StatelessWidget {

  const _PetSelectorChip({
    required this.pet,
    required this.isSelected,
    required this.isCaughtUp,
    required this.onTap,
  });
  final PetModel pet;
  final bool isSelected;
  final bool isCaughtUp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const selectedColor = AppTheme.primaryAccent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withAlpha(28)
              : colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? selectedColor
                : colorScheme.outline.withAlpha(70),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: selectedColor, width: 2)
                    : Border.all(
                        color: colorScheme.outline.withAlpha(60),
                      ),
              ),
              child: ClipOval(
                child: pet.profileImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: pet.profileImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => BrandLogo(
                          customSize: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        errorWidget: (_, _, _) => BrandLogo(
                          customSize: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: BrandLogo(
                          customSize: 20,
                          color: isSelected
                              ? selectedColor
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pet.name,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedColor : colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (isCaughtUp)
              Text(
                'All caught up',
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  color: colorScheme.onSurfaceVariant.withAlpha(140),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List a pet for breeding — bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
void showListPetSheet(BuildContext context, WidgetRef ref) {
  final myOwnedPets = ref.read(petProvider).myPets;
  final colorScheme = Theme.of(context).colorScheme;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => _ListPetSheet(myOwnedPets: myOwnedPets),
  );
}

class _ListPetSheet extends StatefulWidget {
  const _ListPetSheet({required this.myOwnedPets});
  final List<PetModel> myOwnedPets;

  @override
  State<_ListPetSheet> createState() => _ListPetSheetState();
}

class _ListPetSheetState extends State<_ListPetSheet> {
  String? _selectedPetId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final availablePets = widget.myOwnedPets
        .where((p) => !p.isBreedingListed)
        .toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer(
      builder: (context, ref, _) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withAlpha(80),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'List a Pet for Breeding',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select which of your pets to add to the discovery pool.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  if (availablePets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.outline.withAlpha(100),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'All your pets are already listed, or you haven\'t added any pets yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.outline.withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: RadioGroup<String>(
                        groupValue: _selectedPetId,
                        onChanged: (val) =>
                            setState(() => _selectedPetId = val),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: availablePets.length,
                          itemBuilder: (context, index) {
                            final pet = availablePets[index];
                            return RadioListTile<String>(
                              value: pet.id,
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
                                    backgroundImage:
                                        pet.profileImageUrl.isNotEmpty
                                        ? NetworkImage(pet.profileImageUrl)
                                        : null,
                                    child: pet.profileImageUrl.isEmpty
                                        ? BrandLogo(
                                            customSize: 18,
                                            color: colorScheme.primary,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    pet.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(left: 48),
                                child: Text(pet.breed),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          _selectedPetId == null ||
                              _isLoading ||
                              availablePets.isEmpty
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              final success = await ref
                                  .read(petProvider.notifier)
                                  .toggleBreedingListing(_selectedPetId!, true);
                              if (!context.mounted) return;
                              setState(() => _isLoading = false);
                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Your pet is now listed for breeding!',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                final error = ref.read(petProvider).error;
                                final errorColor = Theme.of(
                                  context,
                                ).colorScheme.error;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error ??
                                          'Failed to list pet for breeding.',
                                    ),
                                    backgroundColor: errorColor,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text(
                              'Confirm Listing',
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
          ),
        );
      },
    );
  }
}

class _GlassBadge extends StatelessWidget {

  const _GlassBadge({required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
