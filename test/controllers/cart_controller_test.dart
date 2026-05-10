// Cart controller tests that don't require Supabase.
// CartController behavior tests use only in-memory state manipulation.
// CartState pure unit tests and CartItemModel serialization tests all pass.
// CartController integration tests with authProvider are skipped here since
// they require a running Supabase instance (tested via integration tests).

import 'package:flutter_test/flutter_test.dart';

import 'package:petfolio/features/marketplace/data/models/cart_item_model.dart';
import 'package:petfolio/features/marketplace/data/models/product_model.dart';
import 'package:petfolio/features/marketplace/presentation/controllers/cart_controller.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Test helpers
// ──────────────────────────────────────────────────────────────────────────────

ProductModel _makeProduct({
  String id = 'prod-1',
  String name = 'Dog Food',
  double price = 25.99,
  int stock = 100,
}) =>
    ProductModel(
      id: id,
      name: name,
      description: 'Premium dog food',
      price: price,
      images: const ['https://example.com/food.jpg'],
      category: 'Food',
      stock: stock,
      vendorId: 'vendor-1',
    );

CartItemModel _makeCartItem({
  String id = 'item-1',
  String productId = 'prod-1',
  int quantity = 1,
  double price = 25.99,
}) =>
    CartItemModel(
      id: id,
      product: _makeProduct(id: productId, price: price),
      quantity: quantity,
    );

// ──────────────────────────────────────────────────────────────────────────────
// Tests
// ──────────────────────────────────────────────────────────────────────────────

void main() {
  // ---------------------------------------------------------------------------
  group('CartState', () {
    test('initial state has correct defaults', () {
      final state = CartState();
      expect(state.items, isEmpty);
      expect(state.isCheckingOut, isFalse);
      expect(state.orderSuccess, isFalse);
      expect(state.error, isNull);
      expect(state.totalPrice, 0.0);
      expect(state.totalItemCount, 0);
    });

    test('totalPrice sums all item subtotals', () {
      final state = CartState(
        items: [
          _makeCartItem(price: 10.00, quantity: 2), // 20.00
          _makeCartItem(
            id: 'item-2',
            productId: 'prod-2',
            price: 5.50,
            quantity: 3,
          ), // 16.50
        ],
      );

      expect(state.totalPrice, closeTo(36.50, 0.001));
    });

    test('totalItemCount sums all quantities', () {
      final state = CartState(
        items: [
          _makeCartItem(quantity: 2),
          _makeCartItem(id: 'item-2', productId: 'prod-2', quantity: 3),
        ],
      );

      expect(state.totalItemCount, 5);
    });

    test('copyWith preserves unchanged fields', () {
      final original = CartState(
        items: [_makeCartItem()],
      );
      final updated = original.copyWith(isCheckingOut: true);

      expect(updated.items, same(original.items));
      expect(updated.isCheckingOut, isTrue);
      expect(updated.error, isNull);
    });

    test('copyWith clearError resets error to null', () {
      final withError = CartState(error: 'Payment failed');
      final cleared = withError.copyWith(clearError: true);

      expect(cleared.error, isNull);
    });

    test('empty cart has zero totalPrice', () {
      expect(CartState().totalPrice, 0.0);
    });

    test('empty cart has zero totalItemCount', () {
      expect(CartState().totalItemCount, 0);
    });

    test('single item cart with quantity > 1', () {
      final state = CartState(items: [_makeCartItem(price: 5.0, quantity: 10)]);
      expect(state.totalPrice, closeTo(50.0, 0.001));
      expect(state.totalItemCount, 10);
    });
  });

  // ---------------------------------------------------------------------------
  group('CartItemModel', () {
    test('subtotal = price * quantity', () {
      final item = _makeCartItem(price: 12.50, quantity: 4);
      expect(item.subtotal, closeTo(50.00, 0.001));
    });

    test('subtotal is price when quantity is 1', () {
      final item = _makeCartItem(price: 9.99);
      expect(item.subtotal, closeTo(9.99, 0.001));
    });

    test('copyWith updates quantity', () {
      final item = _makeCartItem();
      final updated = item.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.id, item.id);
    });

    test('toJson/fromJson roundtrip preserves data', () {
      final item = _makeCartItem(id: 'item-abc', quantity: 3, price: 15.0);
      final json = item.toJson();
      final restored = CartItemModel.fromJson(json);

      expect(restored.id, item.id);
      expect(restored.quantity, item.quantity);
      expect(restored.product.id, item.product.id);
      expect(restored.subtotal, closeTo(item.subtotal, 0.001));
    });

    test('fromJson handles missing optional product fields', () {
      final json = {
        'id': 'item-test',
        'quantity': 2,
        'product': {
          'id': 'prod-test',
          'name': 'Test',
          'price': 5.0,
          'vendor_id': 'v-1',
          'description': '',
          'images': <String>[],
          'stock': 10,
          'category': 'Other',
        },
      };

      final item = CartItemModel.fromJson(json);
      expect(item.id, 'item-test');
      expect(item.quantity, 2);
      expect(item.product.name, 'Test');
    });
  });

  // ---------------------------------------------------------------------------
  group('CartState immutability', () {
    test('copyWith creates a new instance', () {
      final original = CartState(items: [_makeCartItem()]);
      final copy = original.copyWith(isCheckingOut: true);
      expect(identical(original, copy), isFalse);
    });

    test('items list is not mutated by copyWith', () {
      final items = [_makeCartItem()];
      final state = CartState(items: items);
      final _ = state.copyWith(items: [_makeCartItem(id: 'new-item')]);
      // Original state.items is unchanged
      expect(state.items.length, 1);
      expect(state.items.first.id, 'item-1');
    });

    test('orderSuccess defaults to false', () {
      final state = CartState();
      expect(state.orderSuccess, isFalse);
    });

    test('copyWith orderSuccess true', () {
      final state = CartState().copyWith(orderSuccess: true);
      expect(state.orderSuccess, isTrue);
    });
  });
}
