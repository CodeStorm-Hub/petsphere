import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/match_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_model.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';

import 'main_layout.dart' show bottomNavSpaceFor;

// Tracks which of the user's pets is selected for the discovery tab.
// Scoped to the discovery tab — does NOT override the global activePetProvider.
class DiscoveryPetIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? petId) => state = petId;
}

final discoveryActivePetIdProvider =
    NotifierProvider<DiscoveryPetIdNotifier, String?>(
  DiscoveryPetIdNotifier.new,
);

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
  final List<PetModel> listedPets;
  final double navSpace;
  const MyListingsTab({super.key, required this.listedPets, required this.navSpace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () => ref.read(petProvider.notifier).reload(),
      child: listedPets.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: navSpace),
              children: [
                const SizedBox(height: 100),
                BrandLogo(customSize: 64, color: colorScheme.outline.withAlpha(100)),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "You haven't listed any pets yet.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap "New Listing" to add your pet to discovery.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton(
                    onPressed: () => showListPetSheet(context, ref),
                    child: const Text('Start Listing'),
                  ),
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
                      borderRadius: BorderRadius.circular(16)),
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
                              color: colorScheme.primary)
                          : null,
                    ),
                    title: Text(pet.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pet.breed} • ${pet.animalType}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: colorScheme.error),
                      onPressed: () async {
                        final success = await ref
                            .read(petProvider.notifier)
                            .toggleBreedingListing(pet.id, false);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${pet.name} removed from breeding listings.'),
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
  final bool hasActivePet;
  final bool isPetLoading;

  const DiscoveryTab({super.key, 
    required this.hasActivePet,
    required this.isPetLoading,
  });

  @override
  ConsumerState<DiscoveryTab> createState() => DiscoveryTabState();
}

class DiscoveryTabState extends ConsumerState<DiscoveryTab>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  String? filterAnimal; // null = For You
  final Set<String> dismissedPetIds = {};
  // Tracks pets whose discovery feeds are known to be empty after loading.
  final Set<String> allCaughtUpPetIds = {};

  // Drag tracking
  double _dragX = 0.0;
  bool _isAnimating = false;

  // Per-swipe state captured before animation completes
  PetModel? _swipingPet;
  bool? _pendingLike;

  // Two controllers: one for commit-swipe, one for snap-back
  late AnimationController _swipeOutController;
  late AnimationController _snapBackController;
  late Animation<double> _swipeOutAnim;
  late Animation<double> _snapBackAnim;

  static const _filterLabels = ['For You', 'Dogs', 'Cats', 'Nearby'];
  static const _filterValues = [null, 'Dog', 'Cat', 'Nearby'];

  @override
  void initState() {
    super.initState();
    _swipeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _snapBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _swipeOutController.addListener(_onSwipeOutFrame);
    _swipeOutController.addStatusListener(_onSwipeOutStatus);
    _snapBackController.addListener(_onSnapBackFrame);
    _snapBackController.addStatusListener(_onSnapBackStatus);

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
    _swipeOutController.removeListener(_onSwipeOutFrame);
    _swipeOutController.removeStatusListener(_onSwipeOutStatus);
    _snapBackController.removeListener(_onSnapBackFrame);
    _snapBackController.removeStatusListener(_onSnapBackStatus);
    _swipeOutController.dispose();
    _snapBackController.dispose();
    super.dispose();
  }

  // ── Animation callbacks ──────────────────────────────────────────────────

  void _onSwipeOutFrame() {
    if (mounted) setState(() => _dragX = _swipeOutAnim.value);
  }

  void _onSwipeOutStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final pet = _swipingPet;
    final liked = _pendingLike;
    _swipingPet = null;
    _pendingLike = null;
    if (!mounted || pet == null || liked == null) return;

    final allPets = ref.read(matchProvider).discoveryPets;
    setState(() {
      _dragX = 0;
      dismissedPetIds.add(pet.id);
      _clampIndex(allPets);
      _isAnimating = false;
    });

    if (!liked) return;

    ref.read(matchProvider.notifier).sendLikeRequest(pet.id).then((success) {
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Liked ${pet.name}! 🐾'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      setState(() => dismissedPetIds.remove(pet.id));
      final error = ref.read(matchProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Could not send like. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _onSnapBackFrame() {
    if (mounted) setState(() => _dragX = _snapBackAnim.value);
  }

  void _onSnapBackStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {
        _dragX = 0;
        _isAnimating = false;
      });
    }
  }

  // ── Gesture handlers ─────────────────────────────────────────────────────

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() => _dragX += details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details, double screenWidth) {
    if (_isAnimating) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final threshold = screenWidth * 0.28;
    if (_dragX > threshold || velocity > 500) {
      _commitSwipe(true, screenWidth);
    } else if (_dragX < -threshold || velocity < -500) {
      _commitSwipe(false, screenWidth);
    } else {
      _snapBack();
    }
  }

  void _snapBack() {
    _snapBackAnim = Tween<double>(begin: _dragX, end: 0).animate(
      CurvedAnimation(parent: _snapBackController, curve: Curves.elasticOut),
    );
    _snapBackController.reset();
    _snapBackController.forward();
    setState(() => _isAnimating = true);
  }

  void _commitSwipe(bool liked, double screenWidth) {
    final filteredPets =
        _applyFilter(ref.read(matchProvider).discoveryPets);
    if (_isAnimating || filteredPets.isEmpty) return;
    final pet = filteredPets[currentIndex];
    _swipingPet = pet;
    _pendingLike = liked;

    final endX =
        liked ? screenWidth * 1.5 : -screenWidth * 1.5;
    _swipeOutAnim = Tween<double>(begin: _dragX, end: endX).animate(
      CurvedAnimation(
          parent: _swipeOutController, curve: Curves.easeOutCubic),
    );
    _swipeOutController.reset();
    _swipeOutController.forward();
    setState(() => _isAnimating = true);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<PetModel> _applyFilter(List<PetModel> allPets) {
    final visible =
        allPets.where((p) => !dismissedPetIds.contains(p.id)).toList();
    if (filterAnimal == null) return visible;
    if (filterAnimal == 'Nearby') {
      return [...visible]
        ..sort((a, b) =>
            _fakeDistanceMi(a).compareTo(_fakeDistanceMi(b)));
    }
    return visible.where((p) => p.animalType == filterAnimal).toList();
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

  // ── Pet selector ─────────────────────────────────────────────────────────

  void _selectPet(PetModel pet) {
    // Stop any in-flight swipe animation cleanly before switching.
    if (_isAnimating) {
      _swipeOutController.stop();
      _snapBackController.stop();
      _isAnimating = false;
      _swipingPet = null;
      _pendingLike = null;
    }
    ref.read(discoveryActivePetIdProvider.notifier).select(pet.id);
    setState(() {
      dismissedPetIds.clear();
      currentIndex = 0;
      _dragX = 0;
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
      // A load just finished with an empty feed for the selected pet.
      final loadFinishedEmpty =
          prev?.isLoading == true && !next.isLoading && next.discoveryPets.isEmpty;

      if (!petsChanged && !loadFinishedEmpty) return;

      final currentIds = next.discoveryPets.map((p) => p.id).toSet();
      setState(() {
        if (petsChanged) {
          dismissedPetIds.removeWhere((id) => !currentIds.contains(id));
          _clampIndex(next.discoveryPets);
        }
        if (loadFinishedEmpty) {
          final selId = ref.read(discoveryActivePetIdProvider) ??
              ref.read(petProvider).activePet?.id;
          if (selId != null) allCaughtUpPetIds.add(selId);
        }
      });
    });

    final matchState = ref.watch(matchProvider);
    final filteredPets = _applyFilter(matchState.discoveryPets);
    final hasPets = filteredPets.isNotEmpty;
    final navSpace = bottomNavSpaceFor(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isPetLoading || matchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!widget.hasActivePet) {
      return Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24, 96, 24, 24 + navSpace),
            children: [
              BrandLogo(customSize: 64, color: colorScheme.outline.withAlpha(100)),
              const SizedBox(height: 16),
          const Center(
            child: Text(
              'Add a pet to start discovering breeding matches.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              onPressed: () => context.push('/add_pet'),
              icon: const Icon(Icons.add),
              label: const Text('Add Pet'),
            ),
          ),
        ],
      );
        },
      );
    }

    if (matchState.error != null && !hasPets) {
      return RefreshIndicator(
        onRefresh: () => ref.read(matchProvider.notifier).refresh(),
        child: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 96, 24, 24 + navSpace),
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  matchState.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error),
                ),
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(matchProvider.notifier).refresh(),
                    child: const Text('Try Again'),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    final myPets = ref.watch(petProvider).myPets;

    return Column(
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: List.generate(_filterLabels.length, (i) {
              final value = _filterValues[i];
              final isSelected = filterAnimal == value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    filterAnimal = value;
                    currentIndex = 0;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withAlpha(38)
                          : colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withAlpha(80),
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
                  onRefresh: () =>
                      ref.read(matchProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(24, 96, 24, 24 + navSpace),
                    children: [
                      BrandLogo(
                          customSize: 64,
                          color: colorScheme.outline.withAlpha(100)),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No more pets available. Check back soon!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final sw = MediaQuery.of(context).size.width;
                    // Responsive button sizes clamped for phone → tablet
                    final skipSize = (sw * 0.158).clamp(52.0, 70.0);
                    final starSize = (sw * 0.138).clamp(44.0, 60.0);
                    final likeSize = (sw * 0.198).clamp(64.0, 84.0);
                    final hPad = (sw * 0.048).clamp(12.0, 24.0);
                    final btnGap = sw * 0.045;

                    return Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, navSpace),
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                // Background card (next in queue)
                                if (filteredPets.length > 1)
                                  Positioned(
                                    bottom: 0,
                                    left: 12,
                                    right: 12,
                                    top: 8,
                                    child: Transform.scale(
                                      scale: 0.95,
                                      child: PetCard(
                                        pet: filteredPets[(currentIndex + 1) %
                                            filteredPets.length],
                                        isBackground: true,
                                        dragX: 0,
                                      ),
                                    ),
                                  ),

                                // Foreground card — draggable
                                GestureDetector(
                                  onHorizontalDragUpdate: _onDragUpdate,
                                  onHorizontalDragEnd: (d) =>
                                      _onDragEnd(d, screenWidth),
                                  child: Transform.translate(
                                    offset: Offset(
                                      _dragX,
                                      _dragX.abs() * 0.05,
                                    ),
                                  child: Transform.rotate(
                                    angle: (_dragX / screenWidth) * 0.35,
                                    child: RepaintBoundary(
                                      child: PetCard(
                                        pet: filteredPets[currentIndex],
                                        isBackground: false,
                                        dragX: _dragX,
                                        onTap: () => context.push(
                                            '/pet/${filteredPets[currentIndex].id}'),
                                      ),
                                    ),
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Action buttons ────────────────────────
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Skip
                                ActionButton(
                                  size: skipSize,
                                  color: colorScheme.surfaceContainerHighest,
                                  borderColor:
                                      colorScheme.outline.withAlpha(80),
                                  child: Icon(Icons.close_rounded,
                                      size: skipSize * 0.42,
                                      color: colorScheme.onSurfaceVariant),
                                  onTap: () =>
                                      _commitSwipe(false, screenWidth),
                                ),
                                SizedBox(width: btnGap),
                                // Profile details
                                ActionButton(
                                  size: starSize,
                                  color: colorScheme.surfaceContainerHighest,
                                  borderColor:
                                      colorScheme.outline.withAlpha(80),
                                  child: Icon(Icons.star_rounded,
                                      size: starSize * 0.44,
                                      color: colorScheme.secondary),
                                  onTap: () => context.push(
                                      '/pet/${filteredPets[currentIndex].id}'),
                                ),
                                SizedBox(width: btnGap),
                                // Like
                                ActionButton(
                                  size: likeSize,
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary,
                                      colorScheme.primary.withAlpha(180)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shadowColor:
                                      colorScheme.primary.withAlpha(77),
                                  child: Icon(Icons.favorite,
                                      size: likeSize * 0.44,
                                      color: colorScheme.onPrimary),
                                  onTap: () =>
                                      _commitSwipe(true, screenWidth),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pet card — shows image, info section, and swipe overlays
// ─────────────────────────────────────────────────────────────────────────────
class PetCard extends StatelessWidget {
  final PetModel pet;
  final bool isBackground;
  final double dragX;
  final VoidCallback? onTap;

  const PetCard({super.key, 
    required this.pet,
    required this.isBackground,
    required this.dragX,
    this.onTap,
  });

  String _energyLabel() {
    final v = (pet.name.length + pet.age * 3) % 10;
    final e = 50 + v * 5;
    if (e >= 85) return 'High';
    if (e >= 65) return 'Medium';
    return 'Calm';
  }

  String _healthLabel() {
    final v = (pet.breed.length + pet.age) % 10;
    final h = 60 + v * 4;
    if (h >= 88) return 'Perfect';
    if (h >= 70) return 'Good';
    return 'Fair';
  }

  String _socialLabel() {
    final v = (pet.animalType.length + pet.name.length) % 10;
    final s = 55 + v * 4;
    if (s >= 85) return 'Friendly';
    if (s >= 65) return 'Sociable';
    return 'Reserved';
  }

  @override
  Widget build(BuildContext context) {
    final distanceMi = (pet.id.hashCode.abs() % 25) + 1;
    final likeOpacity = isBackground
        ? 0.0
        : (dragX / 120).clamp(0.0, 1.0).toDouble();
    final nopeOpacity = isBackground
        ? 0.0
        : (-dragX / 120).clamp(0.0, 1.0).toDouble();
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isBackground ? null : onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardH = constraints.maxHeight;
          final cardW = constraints.maxWidth;
          // Responsive font sizes based on card dimensions
          final nameFontSize = (cardH * 0.058).clamp(18.0, 28.0);
          final subFontSize = (cardH * 0.036).clamp(12.0, 16.0);
          final overlayFontSize = (cardW * 0.082).clamp(20.0, 34.0);

          return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isBackground
                ? []
                : [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha(60),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
            border:
                Border.all(color: colorScheme.outline.withAlpha(80), width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ── Photo ─────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Pet image
                    pet.profileImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: pet.profileImageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => _imageFallback(colorScheme),
                          )
                        : _imageFallback(colorScheme),

                    // Like overlay (secondary, right swipe)
                    if (!isBackground)
                      Positioned.fill(
                        child: Opacity(
                          opacity: likeOpacity,
                          child: Container(
                            color:
                                colorScheme.secondary.withAlpha(102),
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: colorScheme.secondary,
                                    width: 2.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'LIKE',
                                style: TextStyle(
                                  color: colorScheme.secondary,
                                  fontSize: overlayFontSize,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Nope overlay (error, left swipe)
                    if (!isBackground)
                      Positioned.fill(
                        child: Opacity(
                          opacity: nopeOpacity,
                          child: Container(
                            color: colorScheme.error.withAlpha(102),
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: colorScheme.error, width: 2.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'NOPE',
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontSize: overlayFontSize,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // DistanceBadge
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: colorScheme.outline.withAlpha(80)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                size: 13,
                                color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              '$distanceMi mi away',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Verified badge
                    if (pet.isVerified)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.verified,
                              size: 18, color: colorScheme.onPrimary),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Info ──────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: cardW - 32, // match horizontal padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  pet.name,
                                  style: TextStyle(
                                    fontSize: nameFontSize,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withAlpha(38),
                                  shape: BoxShape.circle,
                                ),
                                child: BrandLogo(
                                    size: BrandLogoSize.small,
                                    color: colorScheme.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${pet.age} yr${pet.age == 1 ? '' : 's'} • ${pet.breed}',
                            style: TextStyle(
                              fontSize: subFontSize,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _TraitBadge(
                                  label: 'Energy',
                                  value: _energyLabel(),
                                  fontSize: subFontSize),
                              const SizedBox(width: 6),
                              _TraitBadge(
                                  label: 'Health',
                                  value: _healthLabel(),
                                  fontSize: subFontSize),
                              const SizedBox(width: 6),
                              _TraitBadge(
                                  label: 'Social',
                                  value: _socialLabel(),
                                  fontSize: subFontSize),
                            ],
                          ),
                        ],
                      ),
                    ),
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

  Widget _imageFallback(ColorScheme colorScheme) => Container(
        color: colorScheme.surface,
        child: Center(
          child: BrandLogo(customSize: 80, color: colorScheme.primary),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Nearby Tab
// ─────────────────────────────────────────────────────────────────────────────
class NearbyTab extends ConsumerWidget {
  const NearbyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchProvider);
    final colorScheme = Theme.of(context).colorScheme;
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
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No nearby pets found.')),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + navSpace),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final pet = sorted[index];
                final dist = _distanceMi(pet);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          colorScheme.surfaceContainerHighest,
                      backgroundImage: pet.profileImageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(pet.profileImageUrl)
                          : null,
                      child: pet.profileImageUrl.isEmpty
                          ? BrandLogo(
                              size: BrandLogoSize.small,
                              color: colorScheme.onSurfaceVariant)
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(pet.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        if (pet.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified,
                              size: 14, color: colorScheme.primary),
                        ],
                      ],
                    ),
                    subtitle: Text('${pet.breed} • ${pet.age} yrs'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: colorScheme.primary),
                        Text(
                          '$dist mi',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => context.push('/pet/${pet.id}'),
                  ),
                );
              },
            ),
    );
  }

  int _distanceMi(PetModel pet) => (pet.id.hashCode.abs() % 25) + 1;
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────
class _TraitBadge extends StatelessWidget {
  final String label;
  final String value;
  final double fontSize;
  const _TraitBadge({
    required this.label,
    required this.value,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelFontSize = (fontSize * 0.82).clamp(9.0, 12.0);
    final valueFontSize = fontSize.clamp(11.0, 14.0);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(color: colorScheme.outline.withAlpha(80)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: labelFontSize,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final LinearGradient? gradient;
  final Widget child;
  final VoidCallback onTap;

  const ActionButton({super.key, 
    required this.size,
    required this.child,
    required this.onTap,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
          boxShadow: shadowColor != null
              ? [
                  BoxShadow(
                    color: shadowColor!,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ]
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Center(child: child),
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
  final Set<String> allCaughtUpPetIds;
  final ValueChanged<PetModel> onPetSelected;

  const PetSelectorBar({super.key, 
    required this.allCaughtUpPetIds,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPets = ref.watch(petProvider).myPets;
    if (myPets.length <= 1) return const SizedBox.shrink();

    final selectedId = ref.watch(discoveryActivePetIdProvider) ??
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
  final PetModel pet;
  final bool isSelected;
  final bool isCaughtUp;
  final VoidCallback onTap;

  const _PetSelectorChip({
    required this.pet,
    required this.isSelected,
    required this.isCaughtUp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = AppTheme.primaryAccent;

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
                        color: colorScheme.outline.withAlpha(60), width: 1),
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
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
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
  showModalBottomSheet(
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
  final List<PetModel> myOwnedPets;
  const _ListPetSheet({required this.myOwnedPets});

  @override
  State<_ListPetSheet> createState() => _ListPetSheetState();
}

class _ListPetSheetState extends State<_ListPetSheet> {
  String? _selectedPetId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final availablePets =
        widget.myOwnedPets.where((p) => !p.isBreedingListed).toList();
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
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
                          Icon(Icons.info_outline,
                              color: colorScheme.outline.withAlpha(100),
                              size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'All your pets are already listed, or you haven\'t added any pets yet.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: colorScheme.outline.withAlpha(100)),
                          ),
                        ],
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(context).size.height * 0.4,
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
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
                                    backgroundImage:
                                        pet.profileImageUrl.isNotEmpty
                                            ? NetworkImage(
                                                pet.profileImageUrl)
                                            : null,
                                    child: pet.profileImageUrl.isEmpty
                                        ? BrandLogo(
                                            customSize: 18,
                                            color: colorScheme.primary)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    pet.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
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
                          _selectedPetId == null || _isLoading || availablePets.isEmpty
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);
                                  final success = await ref
                                      .read(petProvider.notifier)
                                      .toggleBreedingListing(
                                          _selectedPetId!, true);
                                  if (!context.mounted) return;
                                  setState(() => _isLoading = false);
                                  if (success) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Your pet is now listed for breeding!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else {
                                    final error =
                                        ref.read(petProvider).error;
                                    final errorColor = Theme.of(context)
                                        .colorScheme
                                        .error;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(error ??
                                            'Failed to list pet for breeding.'),
                                        backgroundColor: errorColor,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
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
                                  color: colorScheme.onPrimary),
                            )
                          : const Text(
                              'Confirm Listing',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
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
