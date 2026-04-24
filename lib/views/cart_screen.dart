import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/cart_controller.dart';
import 'components/cart_item_tile.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final theme = Theme.of(context);

    ref.listen<CartState>(cartProvider, (prev, next) {
      if (next.orderSuccess && !(prev?.orderSuccess ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Order placed successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF81C784),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.push('/orders');
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
<<<<<<< HEAD
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
            },
            child: Text('Clear', style: TextStyle(color: theme.colorScheme.error)),
          )
=======
          if (cartState.items.isNotEmpty)
            TextButton(
              onPressed: cartState.isCheckingOut
                  ? null
                  : () => ref.read(cartProvider.notifier).clearCart(),
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
>>>>>>> origin/main
        ],
      ),
      body: cartState.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
<<<<<<< HEAD
                  Icon(Icons.shopping_bag_outlined, size: 80, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('Your basket is empty.', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Continue Shopping'),
                  )
=======
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Browse the shop to add items',
                      style: TextStyle(color: Colors.grey.shade400)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.storefront_outlined),
                    label: const Text('Continue Shopping'),
                  ),
>>>>>>> origin/main
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
<<<<<<< HEAD
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
=======
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
>>>>>>> origin/main
                    itemCount: cartState.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return CartItemTile(item: cartState.items[index]);
                    },
                  ),
                ),
<<<<<<< HEAD
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, -8))
                    ]
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          Text(currencyFormat.format(cartState.totalPrice), style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shipping', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          Text('\$5.00', style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormat.format(cartState.totalPrice + 5.0),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                             ref.read(cartProvider.notifier).clearCart();
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: const Text('Order placed successfully!'),
                                 behavior: SnackBarBehavior.floating,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                               ),
                             );
                             context.pop();
                          },
                          child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 18)),
                        ),
                      )
                    ],
                  ),
                )
=======
                _CheckoutBar(
                  total: cartState.totalPrice,
                  itemCount: cartState.totalItemCount,
                  isCheckingOut: cartState.isCheckingOut,
                  currencyFormat: currencyFormat,
                  onCheckout: () => ref.read(cartProvider.notifier).placeOrder(),
                ),
>>>>>>> origin/main
              ],
            ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final int itemCount;
  final bool isCheckingOut;
  final NumberFormat currencyFormat;
  final VoidCallback onCheckout;

  const _CheckoutBar({
    required this.total,
    required this.itemCount,
    required this.isCheckingOut,
    required this.currencyFormat,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    const Text('Total',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(
                  currencyFormat.format(total),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: isCheckingOut ? null : onCheckout,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isCheckingOut
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Place Order',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
