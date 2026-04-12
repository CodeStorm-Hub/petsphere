import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';

class CartItemTile extends ConsumerWidget {
  final CartItemModel item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
                image: item.product.images.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item.product.images[0]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.product.images.isEmpty
                  ? Icon(Icons.inventory_2_outlined,
                      size: 28, color: Colors.grey.shade400)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(item.product.price),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: () {
                          ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity - 1);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () {
                          ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity + 1);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () {
                ref.read(cartProvider.notifier).removeCartItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
