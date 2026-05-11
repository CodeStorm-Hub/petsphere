import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/services/presentation/controllers/pet_friendly_places_controller.dart';
import 'package:petfolio/features/services/data/models/pet_friendly_place_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:petfolio/core/widgets/petfolio_widgets.dart';

class PetFriendlyPlacesScreen extends ConsumerWidget {
  const PetFriendlyPlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(petFriendlyPlaceCategoryProvider);
    final placesAsync = ref.watch(petFriendlyPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pet-Friendly Places',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              // TODO: Implement map view
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: PetFolioGradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _CategoryHeader(ref: ref, selectedCategory: category),
              Expanded(
                child: AsyncValueWidget<List<PetFriendlyPlace>>(
                  value: placesAsync,
                  data: (List<PetFriendlyPlace> places) {
                    if (places.isEmpty) {
                      return const _EmptyPlacesView();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: places.length,
                      itemBuilder: (context, index) => _PlaceCard(place: places[index])
                          .animate()
                          .fadeIn(delay: (100 * index).ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutQuad),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {

  const _CategoryHeader({required this.ref, required this.selectedCategory});
  final WidgetRef ref;
  final String selectedCategory;

  static const categories = [
    {'name': 'Parks', 'icon': Icons.park_outlined},
    {'name': 'Cafes', 'icon': Icons.coffee_outlined},
    {'name': 'Hotels', 'icon': Icons.hotel_outlined},
    {'name': 'Clinics', 'icon': Icons.local_hospital_outlined},
    {'name': 'Stores', 'icon': Icons.shopping_bag_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat['name'] == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => ref
                  .read(petFriendlyPlaceCategoryProvider.notifier)
                  .set(cat['name'] as String),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: 200.ms,
                width: 80,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['name'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {

  const _PlaceCard({required this.place});
  final PetFriendlyPlace place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        child: InkWell(
          onTap: () {
            // TODO: Navigate to detail
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  if (place.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: place.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      height: 180,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Center(
                        child: Icon(Icons.landscape, color: theme.colorScheme.primary),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            place.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Text(
                          '${place.distanceMiles} mi',
                          style: GoogleFonts.dmSans(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${place.reviewCount} reviews • ${place.status ?? 'Open Now'}',
                      style: GoogleFonts.dmSans(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        _FeatureIcon(icon: Icons.wifi, label: 'Free Wifi'),
                        SizedBox(width: 12),
                        _FeatureIcon(icon: Icons.pets, label: 'All Pets'),
                        SizedBox(width: 12),
                        _FeatureIcon(icon: Icons.local_parking, label: 'Parking'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }
}

class _FeatureIcon extends StatelessWidget {

  const _FeatureIcon({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyPlacesView extends StatelessWidget {
  const _EmptyPlacesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No places found',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Try changing your filters or location.'),
        ],
      ),
    );
  }
}
