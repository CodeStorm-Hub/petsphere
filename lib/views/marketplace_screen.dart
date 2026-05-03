import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/marketplace_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'components/product_card.dart';
import 'main_layout.dart' show bottomNavSpaceFor;

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketState = ref.watch(marketplaceProvider);
    final cartState = ref.watch(cartProvider);
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final navSpace = bottomNavSpaceFor(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(marketplaceProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Premium Sliver App Bar ─────────────────────────────────────
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                title: Text(
                  'Pet Shop',
                  style: GoogleFonts.playfairDisplay(
                    textStyle: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.receipt_long_outlined),
                  onPressed: () => context.push('/orders'),
                ),
                _CartButton(count: cartState.totalItemCount),
                const SizedBox(width: 8),
              ],
            ),

            // ── Search & Greeting ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Curated for your companion',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MarketSearchBar(onTap: () => context.push('/search')),
                  ],
                ),
              ),
            ),

            // ── Verified Shops (Multi-Vendor) ──────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Verified Shops',
                          style: GoogleFonts.playfairDisplay(
                            textStyle: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _mockVendors.length,
                      itemBuilder: (context, index) {
                        final vendor = _mockVendors[index];
                        return _VendorCircle(vendor: vendor);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Promotional Banner ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _PromoBanner(
                  title: 'Premium Nutrition',
                  subtitle: 'Up to 30% off selected diets',
                  color: cs.secondaryContainer,
                  onTap: () => ref.read(marketplaceProvider.notifier).setFilter('Food'),
                ),
              ),
            ),

            // ── Sticky Categories ───────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverCategoryDelegate(
                child: Container(
                  color: theme.scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _CategoryChip(label: 'All', value: null, current: marketState.filterCategory),
                        const SizedBox(width: 8),
                        _CategoryChip(label: 'Food', value: 'Food', current: marketState.filterCategory),
                        const SizedBox(width: 8),
                        _CategoryChip(label: 'Toys', value: 'Toys', current: marketState.filterCategory),
                        const SizedBox(width: 8),
                        _CategoryChip(label: 'Beds', value: 'Bedding', current: marketState.filterCategory),
                        const SizedBox(width: 8),
                        _CategoryChip(label: 'Style', value: 'Accessories', current: marketState.filterCategory),
                        const SizedBox(width: 8),
                        _CategoryChip(label: 'Treats', value: 'Treats', current: marketState.filterCategory),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Product Grid ────────────────────────────────────────────────
            if (marketState.products.isEmpty && !marketState.isLoading)
              const SliverFillRemaining(
                child: Center(child: Text('No items found in this category')),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + navSpace),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= marketState.products.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final product = marketState.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/product/${product.id}'),
                        onAdd: () {
                          ref.read(cartProvider.notifier).addProduct(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                    childCount: marketState.products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Components ─────────────────────────────────────────────────────────────

class _CartButton extends StatelessWidget {
  final int count;
  const _CartButton({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined),
          onPressed: () => context.push('/cart'),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

class _MarketSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _MarketSearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withAlpha(40)),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: cs.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Text(
              'Search treats, toys, and more...',
              style: TextStyle(color: cs.onSurfaceVariant.withAlpha(150), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorCircle extends StatelessWidget {
  final Map<String, String> vendor;
  const _VendorCircle({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.primary.withAlpha(100), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: cs.surfaceContainerHighest,
              backgroundImage: CachedNetworkImageProvider(vendor['image']!),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vendor['name']!,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PromoBanner({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OFFER',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                textStyle: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends ConsumerWidget {
  final String label;
  final String? value;
  final String? current;

  const _CategoryChip({required this.label, required this.value, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = current == value;
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => ref.read(marketplaceProvider.notifier).setFilter(value),
      backgroundColor: Colors.transparent,
      selectedColor: cs.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : cs.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? Colors.transparent : cs.outline.withAlpha(60)),
      showCheckmark: false,
    );
  }
}

class _SliverCategoryDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverCategoryDelegate({required this.child});

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverCategoryDelegate oldDelegate) => false;
}

final _mockVendors = [
  {'name': 'Paw Pantry', 'image': 'https://images.unsplash.com/photo-1583512676605-934d23a65ee3?w=200'},
  {'name': 'Fetch & Co', 'image': 'https://images.unsplash.com/photo-1601758124510-52d02ddb7cbd?w=200'},
  {'name': 'Whisker Way', 'image': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200'},
  {'name': 'Bark Boutique', 'image': 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?w=200'},
  {'name': 'Cat Cave', 'image': 'https://images.unsplash.com/photo-1513245535761-07742dd136ff?w=200'},
];
