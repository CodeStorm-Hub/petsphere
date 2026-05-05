import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetFriendlyPlacesScreen extends ConsumerStatefulWidget {
  const PetFriendlyPlacesScreen({super.key});

  @override
  ConsumerState<PetFriendlyPlacesScreen> createState() => _PetFriendlyPlacesScreenState();
}

class _PetFriendlyPlacesScreenState extends ConsumerState<PetFriendlyPlacesScreen> {
  bool _isMapView = true;
  String _selectedCategory = 'Parks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pet-Friendly Explorer', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton.filledTonal(
            onPressed: () => setState(() => _isMapView = !_isMapView),
            icon: Icon(_isMapView ? Icons.list_rounded : Icons.map_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _isMapView ? _MockMap() : _PlacesListView(),
          _SearchOverlay(
            selectedCategory: _selectedCategory,
            onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
          ),
          if (_isMapView) _PlacesCarousel(),
        ],
      ),
      floatingActionButton: _isMapView
          ? FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.my_location_rounded),
            )
          : null,
    );
  }
}

class _MockMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=1000'),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10)],
              ),
              child: const Text('Interactive Map (Supabase Backend Required)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchOverlay extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const _SearchOverlay({required this.selectedCategory, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 110,
      left: 16,
      right: 16,
      child: Column(
        children: [
          SearchBar(
            hintText: 'Search parks, cafes, vets...',
            leading: const Icon(Icons.search_rounded),
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
            elevation: const WidgetStatePropertyAll(8),
            backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surface.withAlpha(245)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'Parks', icon: Icons.park_rounded, isSelected: selectedCategory == 'Parks', onSelected: onCategorySelected),
                _FilterChip(label: 'Cafes', icon: Icons.local_cafe_rounded, isSelected: selectedCategory == 'Cafes', onSelected: onCategorySelected),
                _FilterChip(label: 'Hotels', icon: Icons.hotel_rounded, isSelected: selectedCategory == 'Hotels', onSelected: onCategorySelected),
                _FilterChip(label: 'Vets', icon: Icons.local_hospital_rounded, isSelected: selectedCategory == 'Vets', onSelected: onCategorySelected),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Function(String) onSelected;

  const _FilterChip({required this.label, required this.icon, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : colorScheme.primary),
        selected: isSelected,
        onSelected: (_) => onSelected(label),
        showCheckmark: false,
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _PlacesCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 240,
        padding: const EdgeInsets.only(bottom: 24),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) => _PlaceCard(
            name: index == 0 ? 'Central Dog Park' : index == 1 ? 'Bark & Brew Cafe' : 'Pet Care Hospital',
            image: index == 0 
                ? 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b'
                : index == 1 ? 'https://images.unsplash.com/photo-1554123168-b400f9c8466b' : 'https://images.unsplash.com/photo-1583511655826-05700d52f4d9',
            rating: 4.8 - (index * 0.1),
            distance: '${0.4 + (index * 0.3)} mi',
            status: 'Open Now',
          ),
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final String name;
  final String image;
  final double rating;
  final String distance;
  final String status;

  const _PlaceCard({required this.name, required this.image, required this.rating, required this.distance, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Image.network(image, height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: colorScheme.tertiary, size: 14),
                      const SizedBox(width: 4),
                      Text('$rating', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text(distance, style: TextStyle(color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: colorScheme.tertiary),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(color: colorScheme.tertiary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton.filledTonal(
                      onPressed: () {},
                      icon: const Icon(Icons.directions_rounded, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacesListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 220, left: 20, right: 20, bottom: 40),
      itemCount: 10,
      itemBuilder: (context, index) => _ListPlaceItem(index: index),
    );
  }
}

class _ListPlaceItem extends StatelessWidget {
  final int index;
  const _ListPlaceItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [BoxShadow(color: colorScheme.shadow.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              index % 2 == 0 
                ? 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b'
                : 'https://images.unsplash.com/photo-1583511655826-05700d52f4d9',
              width: 80, 
              height: 80, 
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(index % 2 == 0 ? 'Wagging Tails Park' : 'VetCare Central', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: colorScheme.tertiary, size: 14),
                    const SizedBox(width: 4),
                    const Text('4.9 (120+ reviews)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: colorScheme.tertiary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                  child: Text('Open until 8:00 PM', style: TextStyle(color: colorScheme.tertiary, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${0.8 + index * 0.2} mi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.map_rounded),
                style: IconButton.styleFrom(backgroundColor: colorScheme.secondaryContainer),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

