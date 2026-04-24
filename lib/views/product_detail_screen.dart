import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/cart_controller.dart';
import '../controllers/marketplace_controller.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(productByIdProvider(productId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text('Could not load product',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(productByIdProvider(productId)),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('Product not found',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }
        return _ProductDetailView(product: product);
      },
    );
  }
}

class _ProductDetailView extends ConsumerStatefulWidget {
  final ProductModel product;
  const _ProductDetailView({required this.product});

  @override
  ConsumerState<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<_ProductDetailView> {
  int _quantity = 1;
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final product = widget.product;
    final images = product.images.isNotEmpty ? product.images : <String>[];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: colorScheme.surface.withAlpha(220),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: colorScheme.surface.withAlpha(220),
                  child: IconButton(
                    tooltip: 'Share product',
                    icon: Icon(Icons.share_outlined,
                        color: colorScheme.onSurface),
                    onPressed: () {
                      Share.share(
                        'Check out ${product.name} on PetSphere — \$${product.price.toStringAsFixed(2)}\nhttps://petsphere.app/product/${product.id}',
                        subject: 'PetSphere — ${product.name}',
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (i) =>
                              setState(() => _currentImageIndex = i),
                          itemBuilder: (_, i) => Image.network(
                            images[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.image_not_supported,
                                  size: 64,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                        if (images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  width: _currentImageIndex == i ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == i
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withAlpha(80),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.shopping_bag_outlined,
                          size: 80, color: colorScheme.onSurfaceVariant),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + BESTSELLER badges row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (product.isBestseller) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD54F).withAlpha(60),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department, size: 13, color: Color(0xFF795548)),
                              SizedBox(width: 3),
                              Text(
                                'BESTSELLER',
                                style: TextStyle(
                                  color: Color(0xFF795548),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Star rating row
                  if (product.rating > 0)
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.reviewCount} verified reviews'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          ...List.generate(5, (i) {
                            final filled = i < product.rating.floor();
                            final halfFilled = !filled && i < product.rating;
                            return Icon(
                              filled ? Icons.star : (halfFilled ? Icons.star_half : Icons.star_outline),
                              color: const Color(0xFFFFB300),
                              size: 18,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewCount} Reviews)',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? const Color(0xFF81C784).withAlpha(30)
                              : colorScheme.error.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.stock > 0 ? '${product.stock} in stock' : 'Out of stock',
                          style: TextStyle(
                            color: product.stock > 0 ? const Color(0xFF506453) : colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Eco / feature tags
                  if (product.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: product.tags.map((tag) {
                        final icon = _tagIcon(tag);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5FDE6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 14, color: const Color(0xFF506453)),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF506453),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(80),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: colorScheme.outline.withAlpha(40)),
                    ),
                    child: Column(
                      children: [
                        _featureRow(context,
                            Icons.local_shipping_outlined, 'Free Shipping',
                            subtitle: 'Orders over \$25'),
                        Divider(
                            height: 24,
                            color: colorScheme.outline.withAlpha(40)),
                        _featureRow(context,
                            Icons.verified_outlined, 'Quality Assured',
                            subtitle: 'Vet-approved products'),
                        Divider(
                            height: 24,
                            color: colorScheme.outline.withAlpha(40)),
                        _featureRow(context,
                            Icons.replay_outlined, '30-Day Returns',
                            subtitle: 'Easy refund policy'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: colorScheme.outline.withAlpha(60)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_quantity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: _quantity < product.stock
                                  ? () => setState(() => _quantity++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Complementary Products
                  const SizedBox(height: 24),
                  Text(
                    'Complementary Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ComplementaryProducts(currentProductId: product.id, category: product.category),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(16),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${(product.price * _quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: product.stock > 0
                        ? () {
                            for (int i = 0; i < _quantity; i++) {
                              ref.read(cartProvider.notifier).addProduct(product);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Added $_quantity × ${product.name} to cart'),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF81C784),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text(
                      'Add to Cart',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _tagIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'organic': return Icons.eco_outlined;
      case 'non-gmo': return Icons.spa_outlined;
      case 'artisanal': return Icons.handshake_outlined;
      case 'hand-made': return Icons.handyman_outlined;
      case 'eco-friendly': return Icons.recycling_outlined;
      case 'natural': return Icons.nature_outlined;
      case 'premium': return Icons.workspace_premium_outlined;
      case 'healthy': return Icons.favorite_outline;
      default: return Icons.label_outline;
    }
  }

  Widget _featureRow(BuildContext context, IconData icon, String title,
      {String? subtitle}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colorScheme.onSurface)),
            if (subtitle != null)
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}

// Fetches same-category products and shows a horizontal complementary scroll row
class _ComplementaryProducts extends ConsumerWidget {
  final String currentProductId;
  final String category;

  const _ComplementaryProducts({required this.currentProductId, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketState = ref.watch(marketplaceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final complementary = marketState.products
        .where((p) => p.category == category && p.id != currentProductId)
        .take(6)
        .toList();

    if (complementary.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: complementary.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = complementary[index];
          return GestureDetector(
            onTap: () => context.push('/product/${p.id}'),
            child: Container(
              width: 110,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: p.images.isNotEmpty
                        ? Image.network(
                            p.images.first,
                            height: 70,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 70,
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.image_not_supported, color: colorScheme.onSurfaceVariant, size: 28),
                            ),
                          )
                        : Container(
                            height: 70,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.shopping_bag_outlined, color: colorScheme.onSurfaceVariant, size: 28),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${p.price.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
