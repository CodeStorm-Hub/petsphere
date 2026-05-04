import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/marketplace_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/auth_controller.dart';
import 'components/product_card.dart';
import '../utils/layout_utils.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketState = ref.watch(marketplaceProvider);
    final cartState = ref.watch(cartProvider);
    final user = ref.watch(authProvider).user;
    final firstName = (user?.name ?? '').split(' ').first;
    final greeting =
        firstName.isNotEmpty ? 'Welcome back, $firstName' : 'Pet Marketplace';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Marketplace',
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Order History',
            onPressed: () => context.push('/orders'),
          ),
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: cartState.totalItemCount > 0
                    ? 'Shopping cart, ${cartState.totalItemCount} items'
                    : 'Shopping cart',
                onPressed: () => context.push('/cart'),
              ),
              if (cartState.totalItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cartState.totalItemCount}',
                        style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personalized greeting
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Discover curated items for your companions',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // Member Exclusive promo banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Semantics(
              button: true,
              label: 'Member Exclusive: Summer Grooming Kit — Now 20% Off. Tap to browse Grooming.',
              child: GestureDetector(
                onTap: () =>
                    ref.read(marketplaceProvider.notifier).setFilter('Grooming'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExcludeSemantics(
                    child: Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded,
                            color: colorScheme.onPrimary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Member Exclusive',
                                  style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8)),
                              Text('Summer Grooming Kit — Now 20% Off',
                                  style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: colorScheme.onPrimary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Category filter chips — includes Bedding
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _CategoryChip(
                    label: 'All',
                    value: null,
                    current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Food',
                    value: 'Food',
                    current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Toys',
                    value: 'Toys',
                    current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Accessories',
                    value: 'Accessories',
                    current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Bedding',
                    value: 'Bedding',
                    current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Grooming',
                    value: 'Grooming',
                    current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Treats',
                    value: 'Treats',
                    current: marketState.filterCategory),
              ],
            ),
          ),
          Expanded(child: _buildBody(context, ref, marketState)),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, MarketplaceState marketState) {
    final navSpace = bottomNavSpaceFor(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (marketState.isLoading && marketState.products.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: navSpace),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (marketState.error != null && marketState.products.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: navSpace),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: colorScheme.surfaceContainerHighest),
                const SizedBox(height: 16),
                Text(
                  'Failed to load products',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  marketState.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(marketplaceProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (marketState.products.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: navSpace),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_outlined,
                  size: 64, color: colorScheme.surfaceContainerLowest),
              const SizedBox(height: 16),
              Text('No products found',
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(marketplaceProvider.notifier).refresh(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + navSpace),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: marketState.products.length,
        itemBuilder: (context, index) {
          final product = marketState.products[index];
          return ProductCard(
            product: product,
            onTap: () => context.push('/product/${product.id}'),
            onAdd: () {
              ref.read(cartProvider.notifier).addProduct(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check, color: colorScheme.onPrimary, size: 16),
                      const SizedBox(width: 8),
                      Text('${product.name} added to cart'),
                    ],
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip extends ConsumerWidget {
  final String label;
  final String? value;
  final String? current;

  const _CategoryChip(
      {required this.label, required this.value, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(marketplaceProvider.notifier).setFilter(value);
      },
    );
  }
}
