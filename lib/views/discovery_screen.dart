import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/match_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_model.dart';
import '../theme/app_theme.dart';
import 'main_layout.dart' show bottomNavSpaceFor;

// ─────────────────────────────────────────────────────────────────────────────
// Discovery Screen (tab host)
// ─────────────────────────────────────────────────────────────────────────────
class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petProvider);
    final myPets = petState.myPets;
    final listedPets = myPets.where((p) => p.isBreedingListed).toList();
    final navSpace = bottomNavSpaceFor(context);

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
            labelColor: AppTheme.primaryAccent,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryAccent,
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
              onPressed: () => _showListPetSheet(context, ref),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _DiscoverTab(
              hasActivePet: petState.activePet != null,
              isPetLoading: petState.isLoading,
            ),
            const _NearbyTab(),
            _MyListingsTab(listedPets: listedPets, navSpace: navSpace),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Listings Tab
// ─────────────────────────────────────────────────────────────────────────────
class _MyListingsTab extends ConsumerWidget {
  final List<PetModel> listedPets;
  final double navSpace;
  const _MyListingsTab({required this.listedPets, required this.navSpace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(petProvider.notifier).reload(),
      child: listedPets.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: navSpace),
              children: [
                const SizedBox(height: 100),
                const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "You haven't listed any pets yet.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Tap "New Listing" to add your pet to discovery.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton(
                    onPressed: () => _showListPetSheet(context, ref),
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
                      backgroundColor: AppTheme.cardColor,
                      backgroundImage: pet.profileImageUrl.isNotEmpty
                          ? NetworkImage(pet.profileImageUrl)
                          : null,
                      child: pet.profileImageUrl.isEmpty
                          ? const Icon(Icons.pets,
                              color: AppTheme.primaryAccent)
                          : null,
                    ),
                    title: Text(pet.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pet.breed} • ${pet.animalType}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
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
class _DiscoverTab extends ConsumerStatefulWidget {
  final bool hasActivePet;
  final bool isPetLoading;

  const _DiscoverTab({
    required this.hasActivePet,
    required this.isPetLoading,
  });

  @override
  ConsumerState<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<_DiscoverTab>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? _filterAnimal; // null = For You
  final Set<String> _dismissedPetIds = {};

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
      _dismissedPetIds.add(pet.id);
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
      setState(() => _dismissedPetIds.remove(pet.id));
      final error = ref.read(matchProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Could not send like. Please try again.'),
          backgroundColor: Colors.red,
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
    final pet = filteredPets[_currentIndex];
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
        allPets.where((p) => !_dismissedPetIds.contains(p.id)).toList();
    if (_filterAnimal == null) return visible;
    if (_filterAnimal == 'Nearby') {
      return [...visible]
        ..sort((a, b) =>
            _fakeDistanceMi(a).compareTo(_fakeDistanceMi(b)));
    }
    return visible.where((p) => p.animalType == _filterAnimal).toList();
  }

  void _clampIndex(List<PetModel> allPets) {
    final filtered = _applyFilter(allPets);
    if (filtered.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= filtered.length) {
      _currentIndex = filtered.length - 1;
    }
  }

  int _fakeDistanceMi(PetModel pet) => (pet.id.hashCode.abs() % 25) + 1;

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Sync dismissed IDs when the discovery list reloads
    ref.listen<MatchState>(matchProvider, (prev, next) {
      if (prev?.discoveryPets == next.discoveryPets) return;
      final currentIds = next.discoveryPets.map((p) => p.id).toSet();
      if (mounted) {
        setState(() {
          _dismissedPetIds.removeWhere((id) => !currentIds.contains(id));
          _clampIndex(next.discoveryPets);
        });
      }
    });

    final matchState = ref.watch(matchProvider);
    final filteredPets = _applyFilter(matchState.discoveryPets);
    final hasPets = filteredPets.isNotEmpty;
    final navSpace = bottomNavSpaceFor(context);

    if (widget.isPetLoading || matchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!widget.hasActivePet) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24, 96, 24, 24 + navSpace),
        children: [
          const Icon(Icons.pets_outlined, size: 64, color: Colors.grey),
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
    }

    if (matchState.error != null && !hasPets) {
      return RefreshIndicator(
        onRefresh: () => ref.read(matchProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 96, 24, 24 + navSpace),
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              matchState.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
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
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // ── Filter chips ────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: List.generate(_filterLabels.length, (i) {
              final value = _filterValues[i];
              final isSelected = _filterAnimal == value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _filterAnimal = value;
                    _currentIndex = 0;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryAccent.withValues(alpha: 0.15)
                          : AppTheme.cardColor,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryAccent
                            : AppTheme.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _filterLabels[i],
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryAccent
                            : AppTheme.textSecondary,
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
                    children: const [
                      Icon(Icons.favorite_border,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No more pets available. Check back soon!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding:
                      EdgeInsets.fromLTRB(20, 0, 20, navSpace),
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
                                left: 16,
                                right: 16,
                                top: 8,
                                child: Transform.scale(
                                  scale: 0.95,
                                  child: _PetCard(
                                    pet: filteredPets[(_currentIndex + 1) %
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
                                  child: _PetCard(
                                    pet: filteredPets[_currentIndex],
                                    isBackground: false,
                                    dragX: _dragX,
                                    onTap: () => context.push(
                                        '/pet/${filteredPets[_currentIndex].id}'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Action buttons ────────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            // Skip
                            _ActionButton(
                              size: 64,
                              color: const Color(0xFF1A1814),
                              borderColor: const Color(0xFF2E2B26),
                              child: const Icon(Icons.close_rounded,
                                  size: 28,
                                  color: Color(0xFFB8B0A4)),
                              onTap: () =>
                                  _commitSwipe(false, screenWidth),
                            ),
                            const SizedBox(width: 20),
                            // Profile details
                            _ActionButton(
                              size: 56,
                              color: const Color(0xFF1A1814),
                              borderColor: const Color(0xFF2E2B26),
                              child: const Icon(Icons.star_rounded,
                                  size: 26,
                                  color: Color(0xFF4A7C59)),
                              onTap: () => context.push(
                                  '/pet/${filteredPets[_currentIndex].id}'),
                            ),
                            const SizedBox(width: 20),
                            // Like
                            _ActionButton(
                              size: 80,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD4845A),
                                  Color(0xFFB86A44)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shadowColor:
                                  const Color(0x4DD4845A),
                              child: const Icon(Icons.favorite,
                                  size: 36, color: Colors.white),
                              onTap: () =>
                                  _commitSwipe(true, screenWidth),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pet card — shows image, info section, and swipe overlays
// ─────────────────────────────────────────────────────────────────────────────
class _PetCard extends StatelessWidget {
  final PetModel pet;
  final bool isBackground;
  final double dragX;
  final VoidCallback? onTap;

  const _PetCard({
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

    return GestureDetector(
      onTap: isBackground ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF211F1B),
          borderRadius: BorderRadius.circular(32),
          boxShadow: isBackground
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 48,
                    offset: const Offset(0, 24),
                  ),
                ],
          border:
              Border.all(color: const Color(0xFF2E2B26), width: 1.5),
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
                      ? Image.network(
                          pet.profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imageFallback(),
                        )
                      : _imageFallback(),

                  // Like overlay (green, right swipe)
                  if (!isBackground)
                    Positioned.fill(
                      child: Opacity(
                        opacity: likeOpacity,
                        child: Container(
                          color:
                              const Color(0xFF4A7C59).withValues(alpha: 0.4),
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF4A7C59),
                                  width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'LIKE',
                              style: TextStyle(
                                color: Color(0xFF4A7C59),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Nope overlay (red, left swipe)
                  if (!isBackground)
                    Positioned.fill(
                      child: Opacity(
                        opacity: nopeOpacity,
                        child: Container(
                          color: Colors.red.withValues(alpha: 0.4),
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.red, width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NOPE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Distance badge
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1814)
                            .withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: const Color(0xFF2E2B26)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              size: 14,
                              color: Color(0xFFD4845A)),
                          const SizedBox(width: 4),
                          Text(
                            '$distanceMi mi away',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF2EDE4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Verified badge
                  if (pet.isVerified)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1DA1F2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified,
                            size: 20, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ──────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF2EDE4),
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4845A)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pets,
                              size: 22, color: Color(0xFFD4845A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.age} yr${pet.age == 1 ? '' : 's'} • ${pet.breed}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFB8B0A4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _TraitBadge(
                            label: 'Energy',
                            value: _energyLabel()),
                        const SizedBox(width: 8),
                        _TraitBadge(
                            label: 'Health',
                            value: _healthLabel()),
                        const SizedBox(width: 8),
                        _TraitBadge(
                            label: 'Social',
                            value: _socialLabel()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
        color: const Color(0xFF211F1B),
        child: const Center(
          child: Icon(Icons.pets, size: 80, color: Color(0xFFD4845A)),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Nearby Tab
// ─────────────────────────────────────────────────────────────────────────────
class _NearbyTab extends ConsumerWidget {
  const _NearbyTab();

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
                          ? NetworkImage(pet.profileImageUrl)
                          : null,
                      child: pet.profileImageUrl.isEmpty
                          ? Icon(Icons.pets,
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
                          const Icon(Icons.verified,
                              size: 14, color: Color(0xFF1DA1F2)),
                        ],
                      ],
                    ),
                    subtitle: Text('${pet.breed} • ${pet.age} yrs'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Color(0xFFD4845A)),
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
  const _TraitBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1814),
          border: Border.all(color: const Color(0xFF2E2B26)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB8B0A4),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD4845A))),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final LinearGradient? gradient;
  final Widget child;
  final VoidCallback onTap;

  const _ActionButton({
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
                    color: Colors.black.withAlpha(50),
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
// List a pet for breeding — bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
void _showListPetSheet(BuildContext context, WidgetRef ref) {
  final myOwnedPets = ref.read(petProvider).myPets;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
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
                      color: AppTheme.border,
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
                  const Text(
                    'Select which of your pets to add to the discovery pool.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  if (availablePets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.grey, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'All your pets are already listed, or you haven\'t added any pets yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
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
                                    backgroundColor: AppTheme.cardColor,
                                    backgroundImage:
                                        pet.profileImageUrl.isNotEmpty
                                            ? NetworkImage(
                                                pet.profileImageUrl)
                                            : null,
                                    child: pet.profileImageUrl.isEmpty
                                        ? const Icon(Icons.pets,
                                            size: 18,
                                            color: AppTheme.primaryAccent)
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
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(error ??
                                            'Failed to list pet for breeding.'),
                                        backgroundColor: Colors.red,
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
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
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
