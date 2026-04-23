import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/marketplace_controller.dart';
import '../controllers/cart_controller.dart';
import 'components/product_card.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketState = ref.watch(marketplaceProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Order History',
            onPressed: () => context.push('/orders'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cartState.totalItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartState.totalItemCount}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _CategoryChip(
                    label: 'All', value: null, current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Food', value: 'Food', current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Toys', value: 'Toys', current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Accessories',
                    value: 'Accessories',
                    current: marketState.filterCategory),
                const SizedBox(width: 8),
                _CategoryChip(
                    label: 'Treats', value: 'Treats', current: marketState.filterCategory),
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
    if (marketState.isLoading && marketState.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (marketState.error != null && marketState.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Failed to load products',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                marketState.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => ref.read(marketplaceProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (marketState.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No products found',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(marketplaceProvider.notifier).refresh(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
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
                      const Icon(Icons.check, color: Colors.white, size: 16),
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
