import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/features/marketplace/data/models/order_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider — fetches a single order by ID
// ─────────────────────────────────────────────────────────────────────────────
final _orderDetailProvider = FutureProvider.family<OrderModel, String>((
  ref,
  orderId,
) async {
  final data = await supabase
      .from('orders')
      .select()
      .eq('id', orderId)
      .single();
  return OrderModel.fromJson(data);
});

// ─────────────────────────────────────────────────────────────────────────────
// OrderDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(_orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details'), centerTitle: true),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e.toString(), orderId: orderId),
        data: (order) => _OrderDetailBody(order: order),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────
class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dateFmt = DateFormat('MMMM d, y · h:mm a');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Status badge ───────────────────────────────────────────────
            Row(
              children: [
                _StatusChip(status: order.status),
                const Spacer(),
                Text(
                  dateFmt.format(order.createdAt.toLocal()),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Order ID ───────────────────────────────────────────────────
            Text(
              'Order #${order.id.substring(0, 8).toUpperCase()}',
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // ── Tracking stepper ──────────────────────────────────────────
            _TrackingStepper(status: order.status),
            const SizedBox(height: 28),

            // ── Line items ────────────────────────────────────────────────
            Text(
              'Items',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < order.items.length; i++) ...[
                    _LineItemRow(item: order.items[i]),
                    if (i < order.items.length - 1)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: cs.outlineVariant,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (order.shippingAddress != null ||
                order.shippingCity != null ||
                order.shippingName != null) ...[
              Text(
                'Shipping',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.local_shipping_outlined, color: cs.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          [
                                order.shippingName,
                                order.shippingAddress,
                                [
                                      order.shippingCity,
                                      order.shippingState,
                                      order.shippingZip,
                                    ]
                                    .whereType<String>()
                                    .where((s) => s.isNotEmpty)
                                    .join(' '),
                              ]
                              .whereType<String>()
                              .where((s) => s.isNotEmpty)
                              .join('\n'),
                          style: tt.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Price breakdown ────────────────────────────────────────────
            Text(
              'Summary',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _PriceRow('Subtotal', order.total),
                    const _PriceRow('Shipping', 0),
                    Divider(height: 20, color: cs.outlineVariant),
                    _PriceRow(
                      'Total',
                      order.total,
                      isBold: true,
                      color: cs.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Actions ────────────────────────────────────────────────────
            if (order.status == 'pending' || order.status == 'confirmed')
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: cancel order flow
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cancellation request submitted.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Request Cancellation'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tracking stepper widget
// ─────────────────────────────────────────────────────────────────────────────
class _TrackingStepper extends StatelessWidget {
  const _TrackingStepper({required this.status});
  final String status;

  static const _steps = ['pending', 'confirmed', 'shipped', 'delivered'];

  int get _currentIndex {
    final idx = _steps.indexOf(status);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final current = _currentIndex;

    final labels = ['Placed', 'Confirmed', 'Shipped', 'Delivered'];
    final icons = [
      Icons.shopping_bag_outlined,
      Icons.verified_outlined,
      Icons.local_shipping_outlined,
      Icons.home_outlined,
    ];

    return Row(
      children: List.generate(_steps.length, (i) {
        final done = i <= current;
        final isActive = i == current;
        return Expanded(
          child: Column(
            children: [
              // ── connector line ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i > 0 && i <= current
                          ? cs.primary
                          : cs.outlineVariant,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? cs.primary : cs.surfaceContainerHighest,
                      border: isActive
                          ? Border.all(color: cs.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icons[i],
                      size: 18,
                      color: done ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < current ? cs.primary : cs.outlineVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: tt.bodySmall?.copyWith(
                  color: done ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.bold : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chip
// ─────────────────────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg, label) = switch (status) {
      'pending' => (cs.secondaryContainer, cs.onSecondaryContainer, 'Pending'),
      'confirmed' => (cs.primaryContainer, cs.onPrimaryContainer, 'Confirmed'),
      'shipped' => (
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
        'Shipped',
      ),
      'delivered' => (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        'Delivered',
      ),
      'cancelled' => (cs.errorContainer, cs.onErrorContainer, 'Cancelled'),
      _ => (cs.surfaceContainerHighest, cs.onSurfaceVariant, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Line item row
// ─────────────────────────────────────────────────────────────────────────────
class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.item});
  final OrderLineItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.pets, size: 20, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty: ${item.quantity} · \$${item.price.toStringAsFixed(2)} each',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price row
// ─────────────────────────────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  const _PriceRow(this.label, this.amount, {this.isBold = false, this.color});
  final String label;
  final double amount;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: isBold ? FontWeight.bold : null,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            amount == 0 ? 'Free' : '\$${amount.toStringAsFixed(2)}',
            style: style,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.orderId});
  final String error;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load order',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: ${orderId.substring(0, 8).toUpperCase()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
