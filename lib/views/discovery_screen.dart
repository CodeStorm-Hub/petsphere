import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/match_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_model.dart';
import '../theme/app_theme.dart';
import 'main_layout.dart' show bottomNavSpaceFor;

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchProvider);
    final myPets = ref.watch(petProvider).myPets;
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
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.onSurfaceVariant,
            indicatorColor: AppTheme.primary,
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
            // ── TAB 1: DISCOVER (card stack) ─────────────────────────
            _DiscoverTab(pets: matchState.discoveryPets, matchState: matchState, ref: ref),

            // ── TAB 2: NEARBY ────────────────────────────────────────
            _NearbyTab(discoveryPets: matchState.discoveryPets),

            // ── TAB 3: MY LISTINGS ───────────────────────────────────
            RefreshIndicator(
              onRefresh: () => ref.read(petProvider.notifier).reload(),
              child: listedPets.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: navSpace),
                      children: [
                        const SizedBox(height: 100),
                        const Icon(Icons.favorite_border,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Center(
                            child: Text('You haven\'t listed any pets yet.',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 8),
                        const Center(
                            child: Text(
                                'Tap "New Listing" to add your pet to discovery.',
                                style: TextStyle(color: Colors.grey))),
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
                              backgroundImage:
                                  NetworkImage(pet.profileImageUrl),
                            ),
                            title: Text(pet.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
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
                                            '${pet.name} removed from breeding listings.')),
                                  );
                                }
                              },
                            ),
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

// ── Stitch-style card stack discover tab ──────────────────────────────────
class _DiscoverTab extends StatefulWidget {
  final List<PetModel> pets;
  final dynamic matchState;
  final WidgetRef ref;

  const _DiscoverTab({required this.pets, required this.matchState, required this.ref});

  @override
  State<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<_DiscoverTab> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? _filterAnimal; // null = For You
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  bool _isAnimating = false;

  static const _filterLabels = ['For You', 'Dogs', 'Cats', 'Nearby'];
  static const _filterValues = [null, 'Dog', 'Cat', 'Nearby'];

  List<PetModel> get _filteredPets {
    if (_filterAnimal == null || _filterAnimal == 'Nearby') return widget.pets;
    return widget.pets.where((p) => p.animalType == _filterAnimal).toList();
  }

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _swipeAnimation = const AlwaysStoppedAnimation(Offset.zero);
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _swipePet(bool liked) {
    if (_isAnimating || _filteredPets.isEmpty) return;
    setState(() => _isAnimating = true);

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(liked ? 2.0 : -2.0, -0.3),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeInCubic));

    _swipeController.forward(from: 0).then((_) {
      if (mounted) {
        if (liked) {
              final pet = _filteredPets[_currentIndex];
              widget.ref.read(matchProvider.notifier).sendLikeRequest(pet.id);
            }
        setState(() {
          _currentIndex = (_currentIndex + 1) % math.max(1, _filteredPets.length);
          _isAnimating = false;
        });
        _swipeController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPets = _filteredPets;
    final hasPets = filteredPets.isNotEmpty;
    final navSpace = bottomNavSpaceFor(context);

    return Column(
      children: [
        // ── Filter chips ──────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: List.generate(_filterLabels.length, (i) {
              final value = _filterValues[i];
              final isSelected = _filterAnimal == value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filterAnimal = value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.tertiary : AppTheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _filterLabels[i],
                      style: TextStyle(
                        color: isSelected ? AppTheme.onTertiary : AppTheme.onTertiaryContainer,
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

        // ── Card Stack ────────────────────────────────────────────
        Expanded(
          child: !hasPets
              ? Padding(
                  padding: EdgeInsets.only(bottom: navSpace),
                  child: const Center(
                      child: Text('No pets available. Check back soon!')),
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, navSpace),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Background card
                            if (filteredPets.length > 1)
                              Positioned(
                                bottom: 0,
                                left: 16,
                                right: 16,
                                top: 8,
                                child: Transform.scale(
                                  scale: 0.95,
                                  child: _PetCard(pet: filteredPets[(_currentIndex + 1) % filteredPets.length], isBackground: true),
                                ),
                              ),
                            // Foreground card
                            AnimatedBuilder(
                              animation: _swipeController,
                              builder: (context, child) {
                                final offset = _isAnimating
                                    ? _swipeAnimation.value
                                    : Offset.zero;
                                final angle = offset.dx * 0.05;
                                return GestureDetector(
                                  onHorizontalDragEnd: (details) {
                                    if (details.velocity.pixelsPerSecond.dx > 400) {
                                      _swipePet(true);
                                    } else if (details.velocity.pixelsPerSecond.dx < -400) {
                                      _swipePet(false);
                                    }
                                  },
                                  child: Transform.translate(
                                    offset: Offset(
                                      offset.dx * MediaQuery.of(context).size.width,
                                      offset.dy * 100,
                                    ),
                                    child: Transform.rotate(
                                      angle: angle,
                                      child: GestureDetector(
                                        onTap: () => context.push('/pet/${filteredPets[_currentIndex].id}'),
                                        child: _PetCard(pet: filteredPets[_currentIndex], isBackground: false),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // ── Action Buttons ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Skip
                            GestureDetector(
                              onTap: () => _swipePet(false),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 16, offset: const Offset(0, 4))],
                                ),
                                child: const Icon(Icons.close_rounded, size: 28, color: Color(0xFF7F7A74)),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Like (gradient circle, larger)
                            GestureDetector(
                              onTap: () => _swipePet(true),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradientFAB,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x4D99472C), blurRadius: 24, offset: Offset(0, 8)),
                                  ],
                                ),
                                child: const Icon(Icons.favorite, size: 36, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Superlike (star)
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Super-liked! ⭐')),
                                );
                                _swipePet(true);
                              },
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 16, offset: const Offset(0, 4))],
                                ),
                                child: const Icon(Icons.star_rounded, size: 28, color: Color(0xFF506453)),
                              ),
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

// ── Pet card for the card stack ────────────────────────────────────────────
class _PetCard extends StatelessWidget {
  final PetModel pet;
  final bool isBackground;
  const _PetCard({required this.pet, required this.isBackground});

  int _energyLevel() {
    final v = (pet.name.length + pet.age * 3) % 10;
    return 50 + v * 5;
  }
  int _healthScore() {
    final v = (pet.breed.length + pet.age) % 10;
    return 60 + v * 4;
  }
  int _socialScore() {
    final v = (pet.animalType.length + pet.name.length) % 10;
    return 55 + v * 4;
  }

  String _energyLabel() {
    final e = _energyLevel();
    if (e >= 85) return 'High';
    if (e >= 65) return 'Medium';
    return 'Calm';
  }
  String _healthLabel() {
    final h = _healthScore();
    if (h >= 88) return 'Perfect';
    if (h >= 70) return 'Good';
    return 'Fair';
  }
  String _socialLabel() {
    final s = _socialScore();
    if (s >= 85) return 'Friendly';
    if (s >= 65) return 'Sociable';
    return 'Reserved';
  }

  @override
  Widget build(BuildContext context) {
    final distanceMi = (pet.name.hashCode.abs() % 15) + 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isBackground
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF99472C).withAlpha(30),
                  blurRadius: 48,
                  offset: const Offset(0, 24),
                ),
              ],
        border: Border.all(color: AppTheme.outlineVariant.withAlpha(26)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Photo section ────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                pet.profileImageUrl.isNotEmpty
                    ? Image.network(
                        pet.profileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.surfaceContainerLow,
                          child: const Icon(Icons.pets, size: 80, color: Color(0xFF99472C)),
                        ),
                      )
                    : Container(
                        color: AppTheme.surfaceContainerLow,
                        child: const Icon(Icons.pets, size: 80, color: Color(0xFF99472C)),
                      ),
                // Distance badge
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withAlpha(230),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFF99472C)),
                        const SizedBox(width: 4),
                        Text(
                          '$distanceMi miles away',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF35322D)),
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
                      decoration: const BoxDecoration(color: Color(0xFF1DA1F2), shape: BoxShape.circle),
                      child: const Icon(Icons.verified, size: 20, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          // ── Info section ─────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF35322D),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryFixedDim,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pets, size: 22, color: Color(0xFF4E3D00)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.age} yr${pet.age == 1 ? '' : 's'} • ${pet.breed}',
                    style: const TextStyle(fontSize: 15, color: Color(0xFF625E59), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  // Traits bento grid
                  Row(
                    children: [
                      _TraitBadge(label: 'Energy', value: _energyLabel()),
                      const SizedBox(width: 8),
                      _TraitBadge(label: 'Health', value: _healthLabel()),
                      const SizedBox(width: 8),
                      _TraitBadge(label: 'Social', value: _socialLabel()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF625E59), fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF99472C))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Nearby Tab — shows pets sorted by "proximity" (approximated by
// the order they joined, since real GPS is not yet wired).
// When real location is added, sort by distance here.
// ──────────────────────────────────────────────────────────────────
class _NearbyTab extends StatelessWidget {
  final List<dynamic> discoveryPets;
  const _NearbyTab({required this.discoveryPets});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final navSpace = bottomNavSpaceFor(context);

    if (discoveryPets.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: navSpace),
        child: const Center(child: Text('No nearby pets found.')),
      );
    }

    // Show at most 10 as "nearby" (real GPS sorting would go here)
    final nearby = discoveryPets.take(10).toList();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + navSpace),
      itemCount: nearby.length,
      itemBuilder: (context, index) {
        final pet = nearby[index];
        final distanceKm = (index + 1) * 0.8; // Placeholder distance
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: pet.profileImageUrl.isNotEmpty
                  ? NetworkImage(pet.profileImageUrl)
                  : null,
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: pet.profileImageUrl.isEmpty
                  ? Icon(Icons.pets, color: colorScheme.onSurfaceVariant)
                  : null,
            ),
            title: Row(
              children: [
                Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (pet.isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 14, color: Color(0xFF1DA1F2)),
                ],
              ],
            ),
            subtitle: Text('${pet.breed} • ${pet.age} yrs'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                Text(
                  '${distanceKm.toStringAsFixed(1)} km',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            onTap: () => context.push('/pet/${pet.id}'),
          ),
        );
      },
    );
  }
}

void _showListPetSheet(BuildContext context, WidgetRef ref) {
  // Pull authenticated user's pets from petProvider
  final myOwnedPets = ref.read(petProvider).myPets;

  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return _ListPetSheetWidget(myOwnedPets: myOwnedPets);
    },
  );
}

class _ListPetSheetWidget extends StatefulWidget {
  final List<PetModel> myOwnedPets;
  const _ListPetSheetWidget({required this.myOwnedPets});

  @override
  State<_ListPetSheetWidget> createState() => _ListPetSheetWidgetState();
}

class _ListPetSheetWidgetState extends State<_ListPetSheetWidget> {
  String? _selectedPetId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Only show pets that are NOT yet listed for breeding
    final availablePets =
        widget.myOwnedPets.where((p) => !p.isBreedingListed).toList();

    return Consumer(
      builder: (context, ref, child) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'List a Pet for Breeding',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select which of your pets you want to add to the discovery matchmaking pool.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              if (availablePets.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'No pets available to list. All your pets are already listed or you haven\'t added any pets yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: RadioGroup<String>(
                    groupValue: _selectedPetId,
                    onChanged: (val) {
                      setState(() {
                        _selectedPetId = val;
                      });
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availablePets.length,
                      itemBuilder: (context, index) {
                        final pet = availablePets[index];
                        return RadioListTile<String>(
                          title: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(pet.profileImageUrl),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                pet.name,
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          subtitle: Text(pet.breed),
                          value: pet.id,
                          activeColor: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedPetId == null || _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          final success = await ref
                              .read(petProvider.notifier)
                              .toggleBreedingListing(_selectedPetId!, true);
                          if (context.mounted) {
                            setState(() => _isLoading = false);
                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Successfully listed your pet for breeding!',
                                  ),
                                ),
                              );
                            } else {
                              final error = ref.read(petProvider).error;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error ?? 'Failed to list pet for breeding.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Confirm Listing',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
