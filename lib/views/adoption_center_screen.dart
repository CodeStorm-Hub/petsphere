import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';

class AdoptionCenterScreen extends ConsumerStatefulWidget {
  const AdoptionCenterScreen({super.key});

  @override
  ConsumerState<AdoptionCenterScreen> createState() => _AdoptionCenterScreenState();
}

class _AdoptionCenterScreenState extends ConsumerState<AdoptionCenterScreen> {
  int _currentIndex = 0;
  double _swipeProgress = 0.0; // -1.0 to 1.0

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pet Adoption',
          style: GoogleFonts.playfairDisplay(
            textStyle: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Immersive Background Gradient ───────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.primary.withAlpha(200),
                    cs.surface,
                  ],
                ),
              ),
            ),
          ),

          // ── Swipe Stack ────────────────────────────────────────────────
          Positioned.fill(
            top: 100,
            bottom: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: List.generate(
                  math.min(3, _mockPets.length - _currentIndex),
                  (index) {
                    final reverseIndex = 2 - index;
                    final actualIndex = _currentIndex + reverseIndex;
                    if (actualIndex >= _mockPets.length) return const SizedBox.shrink();

                    return _AdoptionSwipeCard(
                      pet: _mockPets[actualIndex],
                      isTop: reverseIndex == 0,
                      onSwipe: (progress) {
                        setState(() => _swipeProgress = progress);
                      },
                      onComplete: () {
                        setState(() {
                          _currentIndex++;
                          _swipeProgress = 0.0;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}

class _AdoptionSwipeCard extends StatefulWidget {
  final Map<String, dynamic> pet;
  final bool isTop;
  final Function(double) onSwipe;
  final VoidCallback onComplete;

  const _AdoptionSwipeCard({
    required this.pet,
    required this.isTop,
    required this.onSwipe,
    required this.onComplete,
  });

  @override
  State<_AdoptionSwipeCard> createState() => _AdoptionSwipeCardState();
}

class _AdoptionSwipeCardState extends State<_AdoptionSwipeCard> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final angle = (_offset.dx / 20) * (math.pi / 180);

    return GestureDetector(
      onPanUpdate: widget.isTop
          ? (details) {
              setState(() {
                _offset += details.delta;
                widget.onSwipe(_offset.dx / 200);
              });
            }
          : null,
      onPanEnd: widget.isTop
          ? (details) {
              if (_offset.dx.abs() > 120) {
                widget.onComplete();
              } else {
                setState(() {
                  _offset = Offset.zero;
                  widget.onSwipe(0.0);
                });
              }
            }
          : null,
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  // ── Hero Image ───────────────────────────────────────────
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: widget.pet['image'],
                      fit: BoxFit.cover,
                    ),
                  ),

                  // ── Glassmorphic Info Overlay ────────────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(180),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${widget.pet['name']}, ${widget.pet['age']}',
                                style: GoogleFonts.playfairDisplay(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.verified, color: Colors.blueAccent, size: 24),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: cs.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                widget.pet['location'],
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: (widget.pet['tags'] as List<String>).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withAlpha(60)),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Swipe Indicators ─────────────────────────────────────
                  if (widget.isTop && _offset.dx > 20)
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: _SwipeStamp(label: 'ADOPT', color: Colors.greenAccent),
                      ),
                    ),
                  if (widget.isTop && _offset.dx < -20)
                    Positioned(
                      top: 40,
                      right: 20,
                      child: Transform.rotate(
                        angle: 0.2,
                        child: _SwipeStamp(label: 'NEXT', color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  final String label;
  final Color color;
  const _SwipeStamp({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
      ),
    );
  }
}



final _mockPets = [
  {
    'name': 'Max',
    'age': '2y',
    'location': 'Downtown Shelter • 2.5mi',
    'image': 'https://images.unsplash.com/photo-1552053831-71594a27632d',
    'tags': ['Energetic', 'Kid Friendly', 'Vaccinated'],
  },
  {
    'name': 'Bella',
    'age': '1y',
    'location': 'Happy Tails • 3.1mi',
    'image': 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8',
    'tags': ['Cuddly', 'Playful', 'Healthy'],
  },
  {
    'name': 'Luna',
    'age': '3y',
    'location': 'Paws Sanctuary • 1.2mi',
    'image': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba',
    'tags': ['Quiet', 'House Trained', 'Spayed'],
  },
];


