import 'package:flutter/material.dart';

class PetGearReviewsScreen extends StatelessWidget {
  const PetGearReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gear Reviews'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _GearHeader(),
          const SizedBox(height: 32),
          Text('Top Rated Gear', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _GearReviewCard(
            productName: 'Ultimate Comfort Harness',
            brand: 'PetFit Pro',
            rating: 4.9,
            price: '\$45.99',
            reviewCount: 1240,
            image: 'https://images.unsplash.com/photo-1544568100-847a948585b9',
          ),
          const SizedBox(height: 16),
          _GearReviewCard(
            productName: 'Automatic Water Fountain',
            brand: 'PureDrop',
            rating: 4.7,
            price: '\$62.50',
            reviewCount: 856,
            image: 'https://images.unsplash.com/photo-1517849845537-4d257902454a',
          ),
          const SizedBox(height: 32),
          _GearCategories(),
        ],
      ),
    );
  }
}

class _GearHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Text(
            'Expert Gear Reviews',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 8),
          Text(
            'Unbiased reviews of the latest pet tech, toys, and essentials.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _GearReviewCard extends StatelessWidget {
  final String productName;
  final String brand;
  final double rating;
  final String price;
  final int reviewCount;
  final String image;

  const _GearReviewCard({
    required this.productName,
    required this.brand,
    required this.rating,
    required this.price,
    required this.reviewCount,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(image, width: 120, fit: BoxFit.cover),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(brand.toUpperCase(), style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text('$rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(' ($reviewCount)', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
}

class _GearCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = ['Harnesses', 'Smart Toys', 'Feeders', 'Beds', 'GPS Trackers'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Explore Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final colorScheme = Theme.of(context).colorScheme;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(cat),
                  onPressed: () {},
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
