import 'package:flutter_test/flutter_test.dart';
import 'package:petsphere/features/marketplace/presentation/controllers/cart_controller.dart';
import 'package:petsphere/features/marketplace/data/models/cart_item_model.dart';
import 'package:petsphere/features/marketplace/data/models/product_model.dart';

void main() {
  group('CartState', () {
    test('creates empty cart', () {
      final state = CartState();

      expect(state.items, isEmpty);
      expect(state.totalPrice, 0.0);
      expect(state.totalItemCount, 0);
      expect(state.isCheckingOut, false);
      expect(state.orderSuccess, false);
    });

    test('addItem with CartItemModel calculates total correctly', () {
      final product = ProductModel(
        id: 'prod-1',
        vendorId: 'vendor-1',
        name: 'Dog Food',
        price: 29.99,
        description: 'Premium dog food',
        images: const [],
        stock: 100,
        category: 'food',
      );

      final item = CartItemModel(id: 'item-1', product: product, quantity: 2);

      final state = CartState(items: [item]);

      expect(state.totalItemCount, 2);
      expect(state.totalPrice, closeTo(59.98, 0.01)); // 29.99 * 2
    });

    test('removeItem reduces total', () {
      final product1 = ProductModel(
        id: 'prod-1',
        vendorId: 'vendor-1',
        name: 'Dog Food',
        price: 29.99,
        description: 'Premium dog food',
        images: const [],
        stock: 100,
        category: 'food',
      );

      final product2 = ProductModel(
        id: 'prod-2',
        vendorId: 'vendor-1',
        name: 'Dog Toy',
        price: 14.99,
        description: 'Squeaky toy',
        images: const [],
        stock: 50,
        category: 'toys',
      );

      final item1 = CartItemModel(id: 'item-1', product: product1);
      final item2 = CartItemModel(id: 'item-2', product: product2);

      var state = CartState(items: [item1, item2]);
      expect(state.totalPrice, closeTo(44.98, 0.01));

      // Remove item1
      final updatedItems = state.items
          .where((item) => item.id != 'item-1')
          .toList();
      state = state.copyWith(items: updatedItems);

      expect(state.totalItemCount, 1);
      expect(state.totalPrice, closeTo(14.99, 0.01));
    });

    test('updateQuantity changes item quantity', () {
      final product = ProductModel(
        id: 'prod-1',
        vendorId: 'vendor-1',
        name: 'Dog Food',
        price: 29.99,
        description: 'Premium dog food',
        images: const [],
        stock: 100,
        category: 'food',
      );

      final item = CartItemModel(id: 'item-1', product: product);
      var state = CartState(items: [item]);

      expect(state.totalPrice, closeTo(29.99, 0.01));

      // Update quantity to 3
      final updatedItem = item.copyWith(quantity: 3);
      state = state.copyWith(items: [updatedItem]);

      expect(state.totalItemCount, 3);
      expect(state.totalPrice, closeTo(89.97, 0.01)); // 29.99 * 3
    });

    test('empty cart has zero items', () {
      final state = CartState();
      expect(state.totalItemCount, 0);
      expect(state.totalPrice, 0.0);
    });

    test('non-empty cart has correct counts', () {
      final product = ProductModel(
        id: 'prod-1',
        vendorId: 'vendor-1',
        name: 'Dog Food',
        price: 29.99,
        description: 'Premium dog food',
        images: const [],
        stock: 100,
        category: 'food',
      );

      final item = CartItemModel(id: 'item-1', product: product);
      final state = CartState(items: [item]);

      expect(state.totalItemCount, 1);
      expect(state.totalPrice, closeTo(29.99, 0.01));
    });

    test('copyWith creates new instance', () {
      final state1 = CartState();
      final state2 = state1.copyWith(isCheckingOut: true);

      expect(state1.isCheckingOut, false);
      expect(state2.isCheckingOut, true);
    });

    test('multiple items calculate correct total', () {
      final product1 = ProductModel(
        id: 'prod-1',
        vendorId: 'vendor-1',
        name: 'Dog Food',
        price: 29.99,
        description: 'Premium dog food',
        images: const [],
        stock: 100,
        category: 'food',
      );

      final product2 = ProductModel(
        id: 'prod-2',
        vendorId: 'vendor-1',
        name: 'Dog Toy',
        price: 14.99,
        description: 'Squeaky toy',
        images: const [],
        stock: 50,
        category: 'toys',
      );

      final product3 = ProductModel(
        id: 'prod-3',
        vendorId: 'vendor-1',
        name: 'Dog Bed',
        price: 49.99,
        description: 'Comfortable bed',
        images: const [],
        stock: 25,
        category: 'furniture',
      );

      final items = [
        CartItemModel(id: 'item-1', product: product1, quantity: 2),
        CartItemModel(id: 'item-2', product: product2),
        CartItemModel(id: 'item-3', product: product3, quantity: 3),
      ];

      final state = CartState(items: items);

      // (29.99 * 2) + (14.99 * 1) + (49.99 * 3)
      // 59.98 + 14.99 + 149.97 = 224.94
      expect(state.totalItemCount, 6);
      expect(state.totalPrice, closeTo(224.94, 0.01));
    });

    test('copyWith preserves other fields', () {
      final product = ProductModel(
        id: 'prod-1',
        vendorId: 'vendor-1',
        name: 'Dog Food',
        price: 29.99,
        description: 'Premium dog food',
        images: const [],
        stock: 100,
        category: 'food',
      );

      final item = CartItemModel(id: 'item-1', product: product);
      final state1 = CartState(
        items: [item],
      );

      final state2 = state1.copyWith(
        isCheckingOut: true,
        error: 'Payment failed',
      );

      expect(state2.items.length, 1);
      expect(state2.isCheckingOut, true);
      expect(state2.error, 'Payment failed');
      expect(state2.orderSuccess, false);
    });

    test('clearError removes error message', () {
      final state1 = CartState(error: 'Some error');
      final state2 = state1.copyWith(clearError: true);

      expect(state1.error, 'Some error');
      expect(state2.error, isNull);
    });
  });
}
