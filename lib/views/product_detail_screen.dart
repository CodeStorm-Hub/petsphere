import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/marketplace_controller.dart';
import '../controllers/cart_controller.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
<<<<<<< HEAD
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final products = ref.read(marketplaceProvider).products;
    final product = products.firstWhere((p) => p.id == widget.productId, orElse: () => products.first);
=======
  Widget build(BuildContext context, WidgetRef ref) {
    final marketState = ref.watch(marketplaceProvider);
>>>>>>> origin/main
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final theme = Theme.of(context);

    if (marketState.isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final idx = marketState.products.indexWhere((p) => p.id == productId);
    if (idx < 0) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('Product not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final product = marketState.products[idx];
    final hasImage = product.images.isNotEmpty;
    final inStock = product.stock > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
<<<<<<< HEAD
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
=======
        title: Text(product.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Product',
            onPressed: () => _showShareSheet(context, product.id, product.name),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(marketplaceProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: hasImage
                        ? Image.network(
                            product.images[0],
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, _, _) =>
                                _ImagePlaceholder(icon: Icons.broken_image),
                          )
                        : _ImagePlaceholder(icon: Icons.inventory_2_outlined),
                  ),
                  if (product.images.length > 1)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: product.images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.images[index],
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, _, _) => Container(
                                  width: 64,
                                  height: 64,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image,
                                      size: 20, color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              currencyFormat.format(product.price),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: inStock
                                    ? const Color(0xFF81C784).withAlpha(26)
                                    : Colors.red.withAlpha(26),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: inStock
                                      ? const Color(0xFF81C784).withAlpha(77)
                                      : Colors.red.withAlpha(77),
                                ),
                              ),
                              child: Text(
                                inStock
                                    ? '${product.stock} in stock'
                                    : 'Out of stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: inStock
                                      ? const Color(0xFF81C784)
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (product.category.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Chip(
                            avatar: const Icon(Icons.category_outlined,
                                size: 16),
                            label: Text(product.category,
                                style: const TextStyle(fontSize: 12)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description.isNotEmpty
                              ? product.description
                              : 'No description available.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: product.description.isNotEmpty
                                ? Colors.black87
                                : Colors.grey.shade400,
                            fontStyle: product.description.isEmpty
                                ? FontStyle.italic
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(
                    inStock ? 'Add to Cart' : 'Out of Stock',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  onPressed: inStock
                      ? () {
                          ref
                              .read(cartProvider.notifier)
                              .addProduct(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text('${product.name} added to cart'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A65),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
>>>>>>> origin/main
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showShareSheet(BuildContext context, String productId, String productName) {
    final shareLink = 'https://petsphere.app/product/$productId';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share $productName',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF8A65).withAlpha(26),
                  ),
                  child: const Icon(Icons.link, color: Color(0xFFFF8A65)),
                ),
                title: const Text('Copy Product Link'),
                subtitle: Text(
                  shareLink,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: shareLink));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Link copied to clipboard!'),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF81C784),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4FC3F7).withAlpha(26),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF4FC3F7)),
                ),
                title: const Text('Send in Message'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final IconData icon;
  const _ImagePlaceholder({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(icon, size: 64, color: Colors.grey.shade400),
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
