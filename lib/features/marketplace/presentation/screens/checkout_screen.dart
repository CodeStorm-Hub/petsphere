import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/features/marketplace/presentation/controllers/cart_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CheckoutScreen — 3-step flow: Shipping → Payment → Confirmation
// ─────────────────────────────────────────────────────────────────────────────
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0; // 0=Shipping, 1=Payment, 2=Confirmation

  // ── Shipping form fields ──────────────────────────────────────────────────
  final _shippingKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  // ── Payment form fields ───────────────────────────────────────────────────
  bool _isPlacingOrder = false;
  String? _placedOrderId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    try {
      final orderId = await ref
          .read(cartProvider.notifier)
          .placeOrder(
            shippingName: _nameCtrl.text.trim(),
            shippingLine1: _line1Ctrl.text.trim(),
            shippingCity: _cityCtrl.text.trim(),
            shippingState: _stateCtrl.text.trim(),
            shippingZip: _zipCtrl.text.trim(),
          );
      if (!mounted) return;
      if (orderId == null) {
        final error =
            ref.read(cartProvider).error ?? 'Payment could not be completed.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _placedOrderId = orderId;
        _step = 2;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order failed: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        bottom: _step < 2
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / 3,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              )
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: switch (_step) {
              0 => _ShippingStep(
                key: const ValueKey('shipping'),
                formKey: _shippingKey,
                nameCtrl: _nameCtrl,
                line1Ctrl: _line1Ctrl,
                line2Ctrl: _line2Ctrl,
                cityCtrl: _cityCtrl,
                stateCtrl: _stateCtrl,
                zipCtrl: _zipCtrl,
                onNext: () {
                  if (_shippingKey.currentState!.validate()) {
                    setState(() => _step = 1);
                  }
                },
              ),
              1 => _PaymentStep(
                key: const ValueKey('payment'),
                cartState: cartState,
                isLoading: _isPlacingOrder,
                onBack: () => setState(() => _step = 0),
                onPlaceOrder: _placeOrder,
              ),
              _ => _ConfirmationStep(
                key: const ValueKey('confirmation'),
                orderId: _placedOrderId ?? '',
                onViewOrder: () {
                  if (_placedOrderId != null) {
                    context.pushReplacement(
                      AppRoutes.orderDetailById(_placedOrderId!),
                    );
                  }
                },
                onContinueShopping: () => context.go(AppRoutes.shop),
              ),
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Shipping Address
// ─────────────────────────────────────────────────────────────────────────────
class _ShippingStep extends StatelessWidget {
  const _ShippingStep({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.line1Ctrl,
    required this.line2Ctrl,
    required this.cityCtrl,
    required this.stateCtrl,
    required this.zipCtrl,
    required this.onNext,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl,
      line1Ctrl,
      line2Ctrl,
      cityCtrl,
      stateCtrl,
      zipCtrl;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _StepHeader(
            icon: Icons.local_shipping_outlined,
            label: 'Shipping Address',
            step: 'Step 1 of 2',
          ),
          const SizedBox(height: 24),
          _Field(
            ctrl: nameCtrl,
            label: 'Full Name',
            hint: 'Jane Smith',
            validator: _required,
          ),
          const SizedBox(height: 16),
          _Field(
            ctrl: line1Ctrl,
            label: 'Address Line 1',
            hint: '123 Paw Lane',
            validator: _required,
          ),
          const SizedBox(height: 16),
          _Field(
            ctrl: line2Ctrl,
            label: 'Address Line 2 (optional)',
            hint: 'Apt 4B',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _Field(
                  ctrl: cityCtrl,
                  label: 'City',
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _Field(
                  ctrl: stateCtrl,
                  label: 'State',
                  hint: 'CA',
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _Field(
                  ctrl: zipCtrl,
                  label: 'ZIP',
                  hint: '90210',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (v) =>
                      (v == null || v.length < 5) ? 'Invalid ZIP' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Continue to Payment'),
          ),
        ],
      ),
    );
  }

  static String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Payment
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    super.key,
    required this.cartState,
    required this.isLoading,
    required this.onBack,
    required this.onPlaceOrder,
  });

  final CartState cartState;
  final bool isLoading;
  final VoidCallback onBack, onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final subtotal = cartState.totalPrice;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _StepHeader(
          icon: Icons.payment_outlined,
          label: 'Payment',
          step: 'Step 2 of 2',
        ),
        const SizedBox(height: 20),

        // ── Order summary card ─────────────────────────────────────────
        Card(
          elevation: 0,
          color: cs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                _SummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                const _SummaryRow('Shipping', 'Free'),
                Divider(height: 24, color: cs.outlineVariant),
                _SummaryRow(
                  'Total',
                  '\$${subtotal.toStringAsFixed(2)}',
                  isBold: true,
                  color: cs.primary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withAlpha(80),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withAlpha(60)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.credit_card_rounded, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Payment details are entered in Stripe PaymentSheet, not stored by PetFolio.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: cs.onSurface),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.lock_outline, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              'Secured with 256-bit SSL encryption',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(100, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: isLoading ? null : onPlaceOrder,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Pay · \$${subtotal.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Confirmation
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmationStep extends StatelessWidget {
  const _ConfirmationStep({
    super.key,
    required this.orderId,
    required this.onViewOrder,
    required this.onContinueShopping,
  });

  final String orderId;
  final VoidCallback onViewOrder, onContinueShopping;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 56,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Placed! 🎉',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "You'll receive a confirmation email shortly.\nYour furry friend's goodies are on the way!",
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          if (orderId.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Order #${orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId}',
                style: tt.labelLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
          FilledButton.icon(
            onPressed: onViewOrder,
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('View Order Details'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onContinueShopping,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.label,
    required this.step,
  });
  final IconData icon;
  final String label, step;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: cs.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              step,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.isBold = false, this.color});
  final String label, value;
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
          Text(value, style: style),
        ],
      ),
    );
  }
}
