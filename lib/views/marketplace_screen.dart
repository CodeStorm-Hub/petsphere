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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => ref.read(marketplaceProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Personalized Greeting Header ────────────────────────────────
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 80,
              title: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning,',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      user?.name?.split(' ').first ?? 'Pet Parent',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _CartButton(count: cartState.totalItemCount),
                ),
                const SizedBox(width: 16),
              ],
            ),

            // ── Search & Filter ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _MarketSearchBar(onTap: () => context.push('/search')),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primary, // Brand color instead of green
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
            ),

            // ── Minimalist Categories ──────────────────────────────────────
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _CategoryChip(label: 'All Items', value: null, current: marketState.filterCategory),
                    const SizedBox(width: 12),
                    _CategoryChip(label: 'Food', value: 'Food', current: marketState.filterCategory),
                    const SizedBox(width: 12),
                    _CategoryChip(label: 'Toys', value: 'Toys', current: marketState.filterCategory),
                    const SizedBox(width: 12),
                    _CategoryChip(label: 'Bedding', value: 'Bedding', current: marketState.filterCategory),
                    const SizedBox(width: 12),
                    _CategoryChip(label: 'Accessories', value: 'Accessories', current: marketState.filterCategory),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

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
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
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
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(brightness == Brightness.dark ? 40 : 8),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
            const SizedBox(width: 12),
            Text(
              'Search Products',
              style: GoogleFonts.dmSans(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => ref.read(marketplaceProvider.notifier).setFilter(value),
      backgroundColor: theme.cardColor,
      selectedColor: cs.primary, // Brand color instead of green
      labelStyle: GoogleFonts.dmSans(
        color: isSelected ? Colors.white : cs.onSurface,
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : cs.outline.withAlpha(40),
        ),
      ),
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


