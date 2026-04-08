import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/marketplace_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketplaceState = ref.watch(marketplaceProvider);
    final products = marketplaceState.products;

    if (marketplaceState.isLoading && products.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (marketplaceState.error != null && products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not load product details.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  marketplaceState.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(marketplaceProvider.notifier).refresh();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    ProductModel? product;
    for (final p in products) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: Text('Product not found.')),
      );
    }

    final resolvedProduct = product;

    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: Text(resolvedProduct.category)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                resolvedProduct.images.isNotEmpty
                    ? resolvedProduct.images[0]
                    : '',
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, _) =>
                    Container(color: Colors.grey.shade200),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resolvedProduct.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(resolvedProduct.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resolvedProduct.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add to Cart'),
                      onPressed: () {
                        ref
                            .read(cartProvider.notifier)
                            .addProduct(resolvedProduct);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
