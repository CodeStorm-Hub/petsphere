import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/cart_controller.dart';
import 'package:petsphere/features/marketplace/presentation/widgets/cart_item_tile.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final cartState = ref.watch(cartProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    ref.listen<CartState>(cartProvider, (prev, next) {
      if (next.orderSuccess && !(prev?.orderSuccess ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: colorScheme.onPrimary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text('Order placed successfully!'),
              ],
            ),
            backgroundColor: colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.push('/orders');
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cartState.items.isNotEmpty)
            TextButton(
              onPressed: cartState.isCheckingOut
                  ? null
                  : () => ref.read(cartProvider.notifier).clearCart(),
              child: Text('Clear', style: TextStyle(color: colorScheme.error)),
            ),
        ],
      ),
      body: cartState.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse the shop to add items',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.storefront_outlined),
                    label: const Text('Continue Shopping'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      return CartItemTile(item: cartState.items[index]);
                    },
                  ),
                ),
                _CheckoutBar(
                  total: cartState.totalPrice,
                  itemCount: cartState.totalItemCount,
                  isCheckingOut: cartState.isCheckingOut,
                  currencyFormat: currencyFormat,
                  onCheckout: () =>
                      ref.read(cartProvider.notifier).placeOrder(),
                ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isFreeShipping = total >= 25;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(15),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value: currencyFormat.format(total),
                    valueColor: colorScheme.onSurface,
                  ),
                  const SizedBox(height: 10),
                  _SummaryRow(
                    label: 'Shipping',
                    value: isFreeShipping
                        ? 'FREE'
                        : '\$${(25 - total).toStringAsFixed(2)} away',
                    valueColor: colorScheme.onTertiary,
                    valueWeight: FontWeight.w700,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      color: colorScheme.outline.withAlpha(60),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        currencyFormat.format(total),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Gradient checkout button
            GestureDetector(
              onTap: isCheckingOut ? null : onCheckout,
              child: Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  gradient: isCheckingOut
                      ? null
                      : LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                  color: isCheckingOut
                      ? colorScheme.surfaceContainerHighest
                      : null,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: isCheckingOut
                      ? null
                      : [
                          BoxShadow(
                            color: colorScheme.primary.withAlpha(40),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isCheckingOut) ...[
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.primary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final FontWeight valueWeight;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.valueWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: valueWeight,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
