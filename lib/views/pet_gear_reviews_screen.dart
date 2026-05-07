import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/gear_reviews_controller.dart';
import '../models/gear_review_models.dart';

class PetGearReviewsScreen extends ConsumerWidget {
  const PetGearReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(filteredGearReviewsProvider);
    final selectedCategory = ref.watch(selectedGearCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gear Reviews'),
        actions: [
          if (selectedCategory != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () => ref.read(selectedGearCategoryProvider.notifier).set(null),
              tooltip: 'Clear filter',
            ),
        ],
      ),
      body: reviewsAsync.when(
        data: (reviews) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _GearHeader(),
            const SizedBox(height: 32),
            _GearCategories(),
            const SizedBox(height: 32),
            Text(
              selectedCategory == null ? 'Top Rated Gear' : '$selectedCategory Reviews',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (reviews.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      const Text('No reviews found for this category.'),
                    ],
                  ),
                ),
              )
            else
              ...reviews.map((review) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _GearReviewCard(review: review),
              )),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
        border: Border.all(color: colorScheme.secondaryContainer.withAlpha(100)),
      ),
      child: const Column(
        children: [
          Text(
            'Expert Gear Reviews',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
          ),
          SizedBox(height: 8),
          Text(
            'Unbiased reviews of the latest pet tech, toys, and essentials.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _GearReviewCard extends StatelessWidget {
  final GearReview review;

  const _GearReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              review.imageUrl ?? 'https://images.unsplash.com/photo-1544568100-847a948585b9',
              width: 130,
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(review.brand.toUpperCase(), style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        if (review.isEditorChoice)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(4)),
                            child: Text('CHOICE', style: TextStyle(color: colorScheme.onTertiaryContainer, fontSize: 8, fontWeight: FontWeight.w900)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(review.productName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.2, letterSpacing: -0.3)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text('${review.rating}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                            Text(' (${review.reviewCount})', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Text(review.price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green)),
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

class _GearCategories extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ['Harnesses', 'Smart Tech', 'Nutrition', 'Health', 'Travel'];
    final selectedCategory = ref.watch(selectedGearCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Explore Categories', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              final colorScheme = Theme.of(context).colorScheme;
              return Container(
                margin: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(selectedGearCategoryProvider.notifier).set(selected ? cat : null);
                  },
                  showCheckmark: false,
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
