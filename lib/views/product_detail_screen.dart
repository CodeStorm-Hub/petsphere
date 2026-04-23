import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/marketplace_controller.dart';
import '../controllers/cart_controller.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final products = ref.read(marketplaceProvider).products;
    final product = products.firstWhere((p) => p.id == widget.productId, orElse: () => products.first);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Let image show through
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const BackButton(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image
            SizedBox(
              height: 400,
              child: Image.network(
                product.images.isNotEmpty ? product.images[0] : '',
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) => Container(color: theme.colorScheme.surfaceContainerHighest),
              ),
            ),

            // Content
            Container(
              transform: Matrix4.translationValues(0.0, -32.0, 0.0), // Pull up to overlap image
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(product.price),
                    style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Quantity Selector
                  Row(
                    children: [
                      Text('Quantity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() { _quantity--; });
                                }
                              },
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('$_quantity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() { _quantity++; });
                              },
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'About this item',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: theme.colorScheme.onSurfaceVariant
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ]
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.shopping_bag_outlined),
          label: Text('Add to Cart - ${currencyFormat.format(product.price * _quantity)}'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999), // full rounded
            ),
          ),
          onPressed: () {
            for(int i = 0; i < _quantity; i++){
               ref.read(cartProvider.notifier).addProduct(product);
            }
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Added $_quantity to cart!'),
                 behavior: SnackBarBehavior.floating,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
               ),
            );
          },
        ),
      ),
    );
  }
}
