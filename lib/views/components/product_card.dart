import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(32), // lg (2rem)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ]
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with top rounded corners only slightly smaller
            Expanded(
<<<<<<< HEAD
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    product.images.isNotEmpty ? product.images[0] : '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: theme.colorScheme.surfaceContainerHighest);
                    },
                    errorBuilder: (ctx, error, stackTrace) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.pets, color: theme.colorScheme.onSurfaceVariant)
                    ),
                  ),
                ),
              ),
=======
              child: product.images.isNotEmpty
                  ? Image.network(
                      product.images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: Icon(Icons.inventory_2_outlined,
                          size: 40, color: Colors.grey.shade400),
                    ),
>>>>>>> origin/main
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     product.name,
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                     style: theme.textTheme.titleSmall?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: theme.colorScheme.onSurface,
                     ),
                   ),
                   const SizedBox(height: 8),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         currencyFormat.format(product.price),
                         style: theme.textTheme.titleMedium?.copyWith(
                           color: theme.colorScheme.primary,
                           fontWeight: FontWeight.bold
                         ),
                       ),
                       InkWell(
                         onTap: onAdd,
                         child: Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             gradient: LinearGradient(
                               colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
                               begin: Alignment.topLeft,
                               end: Alignment.bottomRight,
                             ),
                             shape: BoxShape.circle,
                             boxShadow: [
                               BoxShadow(
                                 color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                 blurRadius: 8,
                                 offset: const Offset(0, 4),
                               )
                             ]
                           ),
                           child: const Icon(Icons.add, color: Colors.white, size: 20),
                         ),
                       )
                     ],
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
