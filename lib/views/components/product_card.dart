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

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                product.images.isNotEmpty ? product.images[0] : '',
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     product.name,
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                   ),
                   const SizedBox(height: 4),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         currencyFormat.format(product.price),
                         style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                       ),
                       InkWell(
                         onTap: onAdd,
                         child: Container(
                           padding: const EdgeInsets.all(4),
                           decoration: BoxDecoration(
                             color: Theme.of(context).primaryColor,
                             shape: BoxShape.circle,
                           ),
                           child: const Icon(Icons.add, color: Colors.white, size: 16),
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
